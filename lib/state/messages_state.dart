import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/persistence_service.dart';
import 'notifications_state.dart';

/// Who sent a message.
enum MessageSender { npc, player }

class ChatMessage {
  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  final MessageSender sender;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'sender': sender.name,
        'text': text,
        'ts': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        sender: j['sender'] == 'player'
            ? MessageSender.player
            : MessageSender.npc,
        text: j['text'] as String,
        timestamp:
            DateTime.tryParse(j['ts'] as String? ?? '') ?? DateTime.now(),
      );
}

class DialogueChoice {
  const DialogueChoice({required this.text, required this.nextNodeId});

  final String text;
  final String nextNodeId;
}

class DialogueNode {
  const DialogueNode({
    required this.id,
    this.npcMessages = const [],
    this.choices = const [],
    this.autoNextNodeId,
    this.triggersEndingId,
  });

  final String id;
  final List<String> npcMessages;
  final List<DialogueChoice> choices;
  final String? autoNextNodeId;

  /// When set, the ending with this id is triggered after the NPC lines on
  /// this node have been delivered (with a 3s dramatic pause).
  final String? triggersEndingId;
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.contactName,
    required this.messages,
    this.dialogueGraph,
    this.currentNodeId,
    this.unreadCount = 0,
    this.isInteractive = false,
    this.avatarColor,
  });

  final String id;
  final String contactName;
  final List<ChatMessage> messages;
  final Map<String, DialogueNode>? dialogueGraph;

  String? currentNodeId;
  int unreadCount;
  bool isInteractive;
  final int? avatarColor;

  ChatMessage? get lastMessage =>
      messages.isEmpty ? null : messages.last;
}

/// Holds every conversation, the currently open thread, branching state,
/// NPC typing state, persistence, and the ending hook.
class MessagesState extends ChangeNotifier {
  MessagesState({PersistenceService? persistence})
      : _persistence = persistence {
    _seed();
    _load();
  }

  static const Duration _typingDelay = Duration(milliseconds: 1500);
  static const Duration _endingDelay = Duration(seconds: 3);

  static const String _kThreadProgress = 'messages.progress.v1';

  final PersistenceService? _persistence;
  final Map<String, ChatThread> _threads = {};
  String? _activeThreadId;
  bool _isNpcTyping = false;

  NotificationsState? _notifications;
  void Function(String threadId)? _bannerNavigator;

  /// Wired from the phone shell. Called when a dialogue node carries
  /// `triggersEndingId`, after the NPC line + the dramatic pause.
  void Function(String endingId)? onEndingTriggered;

  // ---------- Wiring ----------

  void attachNotifications(NotificationsState n) {
    _notifications = n;
  }

  void setBannerTapHandler(void Function(String threadId) handler) {
    _bannerNavigator = handler;
  }

  // ---------- Public API ----------

  List<ChatThread> get threads {
    final list = _threads.values.toList();
    list.sort((a, b) {
      final ta = a.lastMessage?.timestamp ?? DateTime(0);
      final tb = b.lastMessage?.timestamp ?? DateTime(0);
      return tb.compareTo(ta);
    });
    return list;
  }

  ChatThread? threadById(String id) => _threads[id];

  ChatThread? get activeThread =>
      _activeThreadId == null ? null : _threads[_activeThreadId];

  bool get isNpcTyping => _isNpcTyping;

  int get totalUnread =>
      _threads.values.fold(0, (acc, t) => acc + t.unreadCount);

  void openThread(String id) {
    _activeThreadId = id;
    final t = _threads[id];
    if (t != null && t.unreadCount > 0) {
      t.unreadCount = 0;
      _save();
    }
    notifyListeners();
  }

  void closeThread() {
    _activeThreadId = null;
    notifyListeners();
  }

  List<DialogueChoice> get currentChoices {
    final t = activeThread;
    if (t == null || !t.isInteractive || t.dialogueGraph == null) {
      return const [];
    }
    if (_isNpcTyping) return const [];
    final node = t.dialogueGraph![t.currentNodeId];
    return node?.choices ?? const [];
  }

  Future<void> selectChoice(DialogueChoice choice) async {
    final t = activeThread;
    if (t == null) return;
    if (_isNpcTyping) return;

    t.messages.add(ChatMessage(
      sender: MessageSender.player,
      text: choice.text,
      timestamp: DateTime.now(),
    ));
    _isNpcTyping = true;
    notifyListeners();
    _save();

    await _runNode(t, choice.nextNodeId);
  }

  // ---------- Phase 4 / 5 hooks ----------

  /// Ensures a thread exists and wires up its dialogue graph if any.
  /// Idempotent: existing threads are not overwritten.
  void ensureThread(ChatThread thread) {
    if (_threads.containsKey(thread.id)) {
      // If we previously persisted a non-interactive variant but now want
      // to upgrade it to interactive (Phase 5 - first cold-load with the
      // Sheriff hook already fired in a previous Phase 4 run), patch it.
      final existing = _threads[thread.id]!;
      if (!existing.isInteractive && thread.isInteractive) {
        existing.isInteractive = true;
        existing.currentNodeId ??= thread.currentNodeId;
        // Replace the graph on the same instance.
        _threads[thread.id] = ChatThread(
          id: existing.id,
          contactName: existing.contactName,
          messages: existing.messages,
          dialogueGraph: thread.dialogueGraph,
          currentNodeId: existing.currentNodeId ?? thread.currentNodeId,
          unreadCount: existing.unreadCount,
          isInteractive: true,
          avatarColor: existing.avatarColor,
        );
      }
      notifyListeners();
      return;
    }
    _threads[thread.id] = thread;
    _save();
    notifyListeners();
  }

  /// Schedules an NPC line on a thread without requiring the player to be
  /// inside that chat.
  Future<void> deliverNpcMessage(
    String threadId,
    String text, {
    Duration delay = _typingDelay,
  }) async {
    final thread = _threads[threadId];
    if (thread == null) return;

    if (_activeThreadId == threadId) {
      _isNpcTyping = true;
      notifyListeners();
    }

    await Future.delayed(delay);

    thread.messages.add(ChatMessage(
      sender: MessageSender.npc,
      text: text,
      timestamp: DateTime.now(),
    ));

    if (_activeThreadId != threadId) {
      thread.unreadCount += 1;
      _raiseBanner(thread, text);
    }

    _isNpcTyping = false;
    _save();
    notifyListeners();
  }

  void _raiseBanner(ChatThread thread, String body) {
    final n = _notifications;
    if (n == null) return;
    n.push(AppNotification(
      id: 'msg_${thread.id}_${DateTime.now().microsecondsSinceEpoch}',
      appName: 'Wiadomości',
      title: thread.contactName,
      body: body,
      icon: Icons.chat_bubble,
      iconBg: const Color(0xFF34C759),
      onTap: () => _bannerNavigator?.call(thread.id),
    ));
  }

  // ---------- Internals ----------

  Future<void> _runNode(ChatThread thread, String nodeId) async {
    final graph = thread.dialogueGraph;
    if (graph == null) return;
    final node = graph[nodeId];
    if (node == null) return;

    thread.currentNodeId = nodeId;

    for (final line in node.npcMessages) {
      _isNpcTyping = true;
      notifyListeners();

      await Future.delayed(_typingDelay);

      thread.messages.add(ChatMessage(
        sender: MessageSender.npc,
        text: line,
        timestamp: DateTime.now(),
      ));

      if (_activeThreadId != thread.id) {
        thread.unreadCount += 1;
        _raiseBanner(thread, line);
      }

      _isNpcTyping = false;
      _save();
      notifyListeners();
    }

    final auto = node.autoNextNodeId;
    if (auto != null) {
      await _runNode(thread, auto);
      return;
    }

    // Ending fires after the last npc line in this node has been seen.
    final endingId = node.triggersEndingId;
    if (endingId != null) {
      await Future.delayed(_endingDelay);
      onEndingTriggered?.call(endingId);
    }
  }

  // ---------- Reset ----------

  void reset() {
    _threads.clear();
    _activeThreadId = null;
    _isNpcTyping = false;
    _seed();
    notifyListeners();
  }

  // ---------- Persistence ----------

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final list = p.getStringList(_kThreadProgress);
    if (list.isEmpty) return;

    for (final raw in list) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        final id = j['id'] as String;
        final existing = _threads[id];

        // Decode messages.
        final msgs = (j['messages'] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(ChatMessage.fromJson)
            .toList();

        if (existing != null) {
          existing.messages
            ..clear()
            ..addAll(msgs);
          existing.unreadCount = (j['unread'] as int?) ?? 0;
          existing.currentNodeId =
              j['nodeId'] as String? ?? existing.currentNodeId;
        } else {
          // A thread was persisted that we didn't seed (e.g. Szeryf added
          // by the Notes hook in a previous run). Re-create it. Whether
          // it's interactive depends on the saved nodeId / isInteractive
          // flag that we stored.
          _threads[id] = ChatThread(
            id: id,
            contactName: j['name'] as String? ?? id,
            messages: msgs,
            currentNodeId: j['nodeId'] as String?,
            unreadCount: (j['unread'] as int?) ?? 0,
            isInteractive: (j['interactive'] as bool?) ?? false,
            avatarColor: j['avatar'] as int?,
          );
        }
      } catch (_) {
        // Ignore malformed entries; not worth crashing the boot.
      }
    }
  }

  void _save() {
    final p = _persistence;
    if (p == null) return;
    final list = _threads.values.map((t) {
      return jsonEncode({
        'id': t.id,
        'name': t.contactName,
        'avatar': t.avatarColor,
        'unread': t.unreadCount,
        'nodeId': t.currentNodeId,
        'interactive': t.isInteractive,
        'messages': t.messages.map((m) => m.toJson()).toList(),
      });
    }).toList();
    p.setStringList(_kThreadProgress, list);
  }

  // ---------- Seed ----------

  void _seed() {
    final now = DateTime.now();

    final mama = ChatThread(
      id: 'mama',
      contactName: 'Mama',
      avatarColor: 0xFFE08AB0,
      messages: [
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Gdzie jesteś?',
          timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Odezwij się do mnie!',
          timestamp: now.subtract(const Duration(hours: 18)),
        ),
      ],
      isInteractive: false,
    );

    const introLine =
        'Widzę, że udało ci się odblokować jej telefon. Nie mamy wiele czasu. '
        'Oni już wiedzą, że go masz.';

    final nieznanyGraph = <String, DialogueNode>{
      'intro': const DialogueNode(
        id: 'intro',
        choices: [
          DialogueChoice(
            text: 'Kim jesteś? Gdzie jest właścicielka tego telefonu?',
            nextNodeId: 'branch_a',
          ),
          DialogueChoice(
            text: 'To jakiś żart. Idę z tym na policję.',
            nextNodeId: 'branch_b',
          ),
        ],
      ),
      'branch_a': const DialogueNode(
        id: 'branch_a',
        npcMessages: [
          'Przyjacielem. A policja to ostatnie miejsce, do którego powinieneś '
              'teraz iść, jeśli chcesz, żeby przeżyła.',
        ],
        autoNextNodeId: 'convergence',
      ),
      'branch_b': const DialogueNode(
        id: 'branch_b',
        npcMessages: [
          'Policja? Myślisz, że dlaczego musiała uciekać? Nie bądź naiwny.',
        ],
        autoNextNodeId: 'convergence',
      ),
      'convergence': const DialogueNode(
        id: 'convergence',
        npcMessages: [
          'Musisz mi zaufać. Wejdź w Galerię zdjęć. Znajdź fotografię zrobioną '
              'zeszłej nocy. Musisz odszyfrować ukrytą na niej wiadomość, zanim '
              'oni wyłączą ten telefon. Pospiesz się.',
        ],
      ),
    };

    final nieznany = ChatThread(
      id: 'nieznany',
      contactName: 'Nieznany',
      avatarColor: 0xFF3A3A3C,
      messages: [
        ChatMessage(
          sender: MessageSender.npc,
          text: introLine,
          timestamp: now.subtract(const Duration(minutes: 2)),
        ),
      ],
      dialogueGraph: nieznanyGraph,
      currentNodeId: 'intro',
      unreadCount: 1,
      isInteractive: true,
    );

    _threads[mama.id] = mama;
    _threads[nieznany.id] = nieznany;
  }
}
