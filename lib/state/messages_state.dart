import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/l10n_service.dart';
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
  const DialogueChoice({
    required this.text,
    required this.nextNodeId,
    this.trustDeltas = const {},
    this.requiresMinTrust = const {},
    this.requiresMinEvidence,
    this.requiresFlag,
    this.hidden = false,
    this.lockedReasonKey,
  });

  final String text;
  final String nextNodeId;

  /// NPC trust deltas applied when this choice is picked.
  /// Example: `{'mama': -10, 'anita': 5}`. Clamped to [-100, +100] by
  /// [TrustState].
  final Map<String, int> trustDeltas;

  /// Trust thresholds required for this choice to be available.
  /// Example: `{'tomasz': 30}` means the player needs trust >= 30 with
  /// Tomasz before this choice surfaces.
  final Map<String, int> requiresMinTrust;

  /// If set, the player's [EvidenceState.score] must be at least this
  /// value for the choice to be available.
  final int? requiresMinEvidence;

  /// Optional gameplay flag id (e.g. 'inspected_forest_night',
  /// 'route_reconstructed') the choice depends on.
  final String? requiresFlag;

  /// If true, the choice is invisible until its requirements are met.
  /// If false, the choice renders disabled with [lockedReasonKey] tooltip.
  final bool hidden;

  /// Localised reason shown in the tooltip when a non-hidden gated choice
  /// is shown but disabled. ARB key, not literal text.
  final String? lockedReasonKey;
}

class DialogueNode {
  const DialogueNode({
    required this.id,
    this.npcMessages = const [],
    this.choices = const [],
    this.autoNextNodeId,
    this.triggersEndingId,
    this.triggersJournalistHook = false,
  });

  final String id;
  final List<String> npcMessages;
  final List<DialogueChoice> choices;
  final String? autoNextNodeId;

  /// When set, the ending with this id is triggered after the NPC lines on
  /// this node have been delivered (with a 3s dramatic pause).
  final String? triggersEndingId;

  /// When true, the journalist (Anita) thread upgrades to interactive
  /// after the NPC line on this node, opening the path to the TRUTH ending.
  final bool triggersJournalistHook;
}

/// Result of evaluating a [DialogueChoice] against current world state.
/// Carries enough info to render the UI (visible/disabled/visible-active)
/// and to drive the lockedReasonKey tooltip.
class GatedChoice {
  const GatedChoice({
    required this.choice,
    required this.isAvailable,
    required this.isHidden,
  });

  final DialogueChoice choice;
  final bool isAvailable;
  final bool isHidden;

  bool get isVisibleButLocked => !isAvailable && !isHidden;
}

/// External evaluator wired by the phone shell. The shell snapshots
/// `TrustState`, `EvidenceState`, and any flag store, then provides this
/// callback so [MessagesState] can gate choices without a direct
/// dependency on those notifiers.
typedef DialogueGateEvaluator = bool Function(DialogueChoice choice);

class ChatThread {
  ChatThread({
    required this.id,
    required this.contactName,
    required List<ChatMessage> messages,
    this.dialogueGraph,
    this.currentNodeId,
    this.unreadCount = 0,
    this.isInteractive = false,
    this.avatarColor,
  }) : messages = List<ChatMessage>.of(messages);

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

  /// Calculates a realistic typing delay based on message length.
  /// Short messages (~20 chars) get ~2s, long ones (~150 chars) get ~5s.
  static Duration _typingDelayForText(String text) {
    final chars = text.length.clamp(10, 300);
    final ms = 1500 + (chars * 25); // 1500ms base + 25ms per character
    return Duration(milliseconds: ms.clamp(1500, 6000));
  }

  static const String _kThreadProgress = 'game.messages.progress.v1';

  final PersistenceService? _persistence;
  final Map<String, ChatThread> _threads = {};
  String? _activeThreadId;
  bool _isNpcTyping = false;
  bool _isProcessingChoice = false;
  String? _typingThreadId;
  bool _isPaused = false;

  /// Unique ID for the current game session. Incremented on [reset].
  /// Mid-flight NPCs and Choice timers check this to avoid leaking
  /// across game restarts.
  int _gameSessionId = 0;

  NotificationsState? _notifications;
  void Function(String threadId)? _bannerNavigator;

  /// External evaluator for choice availability. Wired by the phone
  /// shell, references TrustState/EvidenceState/flags. If null, all
  /// choices are treated as available (so tests don't need wiring).
  DialogueGateEvaluator? _gateEvaluator;

  /// Trust deltas application. Wired by the phone shell to forward to
  /// TrustState. Null = no-op (test-friendly).
  void Function(Map<String, int>)? _onTrustDeltas;

  /// Wired from the phone shell. Called when a dialogue node carries
  /// `triggersEndingId`, after the NPC line + the dramatic pause.
  void Function(String endingId)? onEndingTriggered;

  /// Wired from the phone shell. Called when a dialogue node sets
  /// `triggersJournalistHook` to true. Used to upgrade Anita's thread
  /// to interactive and deliver her opener.
  void Function()? onJournalistHookTriggered;

  // ---------- Wiring ----------

  void attachNotifications(NotificationsState n) {
    _notifications = n;
  }

  void setBannerTapHandler(void Function(String threadId) handler) {
    _bannerNavigator = handler;
  }

  /// Wire the external evaluator that decides which choices are
  /// available based on trust/evidence/flags.
  void attachGateEvaluator(DialogueGateEvaluator evaluator) {
    _gateEvaluator = evaluator;
  }

  /// Wire the trust deltas sink. The shell forwards to [TrustState.apply].
  void attachTrustSink(void Function(Map<String, int>) sink) {
    _onTrustDeltas = sink;
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

  /// True if a player choice is currently being processed (from tap to 
  /// first NPC message).
  bool get isProcessingChoice => _isProcessingChoice;

  /// True if NPC is typing specifically in the given thread.
  bool isTypingInThread(String threadId) =>
      _isNpcTyping && _typingThreadId == threadId;

  int get totalUnread =>
      _threads.values.fold(0, (acc, t) => acc + t.unreadCount);

  void setPaused(bool value) {
    if (_isPaused == value) return;
    _isPaused = value;
    notifyListeners();
  }

  Future<void> wait(Duration duration, {int? sessionId}) async {
    final sid = sessionId ?? _gameSessionId;
    var remaining = duration;
    while (remaining > Duration.zero) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (sid != _gameSessionId) return;
      if (!_isPaused) {
        remaining -= const Duration(milliseconds: 200);
      }
    }
  }

  /// The current unique session ID.
  int get gameSessionId => _gameSessionId;

  /// True once the player has completed the "Nieznany" intro dialogue
  /// (reached the hint_files node). Used for soft-gating other apps.
  bool get hasCompletedIntro {
    final t = _threads['nieznany'];
    if (t == null) return false;
    // hint_files is the terminal node — if we're there or past it,
    // the intro is done. Also check convergence for cold-load edge case.
    final nodeId = t.currentNodeId;
    return nodeId == 'hint_files' || nodeId == 'convergence' || nodeId == null;
  }

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

  /// Raw list of currently presented choices. Backwards-compatible —
  /// includes ALL choices on the active node regardless of gating.
  /// UI should prefer [gatedChoices] which carries availability info.
  List<DialogueChoice> get currentChoices {
    final t = activeThread;
    if (t == null || !t.isInteractive || t.dialogueGraph == null) {
      return const [];
    }
    // Only hide choices if NPC is typing in THIS specific thread.
    if (_isNpcTyping && _typingThreadId == t.id) return const [];
    final node = t.dialogueGraph![t.currentNodeId];
    return node?.choices ?? const [];
  }

  /// Choices on the active node, evaluated against trust/evidence/flags.
  /// Returns:
  /// - all available + visible-but-locked choices in order;
  /// - hidden choices (with `hidden: true` and unmet requirements) are
  ///   omitted from the list entirely.
  List<GatedChoice> get gatedChoices {
    final raw = currentChoices;
    if (raw.isEmpty) return const [];
    final eval = _gateEvaluator;
    final result = <GatedChoice>[];
    for (final c in raw) {
      final available = eval?.call(c) ?? true;
      if (!available && c.hidden) continue;
      result.add(GatedChoice(
        choice: c,
        isAvailable: available,
        isHidden: false, // hidden+unavailable already filtered above
      ));
    }
    return result;
  }

  Future<void> selectChoice(DialogueChoice choice) async {
    if (_isProcessingChoice) return;
    final t = activeThread;
    if (t == null) return;
    // Only block if NPC is typing in THIS thread.
    if (_isNpcTyping && _typingThreadId == t.id) return;
    
    // Refuse choices that are gated out.
    final eval = _gateEvaluator;
    if (eval != null && !eval(choice)) return;

    _isProcessingChoice = true;
    notifyListeners();

    final sessionId = _gameSessionId;

    // Apply trust deltas BEFORE we render the player line.
    if (choice.trustDeltas.isNotEmpty) {
      _onTrustDeltas?.call(choice.trustDeltas);
    }

    t.messages.add(ChatMessage(
      sender: MessageSender.player,
      text: choice.text,
      timestamp: DateTime.now(),
    ));
    
    _save();
    notifyListeners();

    // NPC "breathing" delay.
    await _wait(const Duration(milliseconds: 1500), sessionId);
    if (sessionId != _gameSessionId) return;

    _isNpcTyping = true;
    _typingThreadId = t.id;
    notifyListeners();

    await _runNode(t, choice.nextNodeId, sessionId);
    
    if (sessionId == _gameSessionId) {
      _isProcessingChoice = false;
      notifyListeners();
    }
  }

  // ---------- Phase 4 / 5 hooks ----------

  /// Ensures a thread exists and wires up its dialogue graph if any.
  /// Idempotent: existing threads keep their messages but get the graph
  /// restored (important for cold-load where graph isn't persisted).
  void ensureThread(ChatThread thread) {
    if (_threads.containsKey(thread.id)) {
      final existing = _threads[thread.id]!;

      // Always restore the dialogue graph if the existing thread lost it
      // (e.g. after cold-load from persistence which doesn't save graphs).
      if (existing.dialogueGraph == null && thread.dialogueGraph != null) {
        _threads[thread.id] = ChatThread(
          id: existing.id,
          contactName: existing.contactName,
          messages: List<ChatMessage>.from(existing.messages),
          dialogueGraph: thread.dialogueGraph,
          currentNodeId: existing.currentNodeId ?? thread.currentNodeId,
          unreadCount: existing.unreadCount,
          isInteractive: true,
          avatarColor: existing.avatarColor ?? thread.avatarColor,
        );
      } else if (!existing.isInteractive && thread.isInteractive) {
        // Upgrade non-interactive to interactive.
        _threads[thread.id] = ChatThread(
          id: existing.id,
          contactName: existing.contactName,
          messages: List<ChatMessage>.from(existing.messages),
          dialogueGraph: thread.dialogueGraph,
          currentNodeId: existing.currentNodeId ?? thread.currentNodeId,
          unreadCount: existing.unreadCount,
          isInteractive: true,
          avatarColor: existing.avatarColor ?? thread.avatarColor,
        );
      }
      notifyListeners();
      return;
    }
    _threads[thread.id] = thread;
    _save();
    notifyListeners();
  }

  /// Upgrades Anita's thread to interactive with the TRUTH-path dialogue
  /// graph. Idempotent — safe to call on cold-load too.
  Future<void> triggerJournalistDialog({bool fromColdLoad = false}) async {
    final dialogues = L10nService.instance.dialogues['threads'] as Map<String, dynamic>? ?? {};
    final dData = dialogues['dziennikarka'] ?? {};
    final dNodes = dData['nodes'] as Map<String, dynamic>? ?? {};
    
    final graph = _buildGraphFromData(dNodes);

    final journalistThread = ChatThread(
      id: 'dziennikarka',
      contactName: dData['contactName'] ?? 'Anita Z. (Gazeta)',
      avatarColor: 0xFFFFCC00,
      messages: [],
      dialogueGraph: graph,
      currentNodeId: 'opener',
      isInteractive: true,
    );

    ensureThread(journalistThread);

    if (fromColdLoad) return;

    // Deliver an opener from Anita — fast, urgent.
    final systemMsgs = dData['systemMessages'] as Map<String, dynamic>? ?? {};
    await deliverNpcMessage(
      'dziennikarka',
      systemMsgs['intro_warning'] ?? 'Kto to?! Gdzie jest N.?! Masz jej telefon — powiedz mi co się stało!',
      delay: const Duration(seconds: 3),
    );
  }

  /// Chapter 2 hook — adds the Witness (Tomasz W.) thread with a
  /// dialogue graph leading to the DAWN ending. The witness is
  /// referenced in the second locked note ("Plan B").
  Future<void> triggerWitnessDialog({bool fromColdLoad = false}) async {
    final dialogues = L10nService.instance.dialogues['threads'] as Map<String, dynamic>? ?? {};
    final tData = dialogues['tomasz'] ?? {};
    final tNodes = tData['nodes'] as Map<String, dynamic>? ?? {};

    final graph = _buildGraphFromData(tNodes);

    final witnessThread = ChatThread(
      id: 'tomasz',
      contactName: tData['contactName'] ?? 'T.W. (sąsiad)',
      avatarColor: 0xFF5AC8FA,
      messages: [],
      dialogueGraph: graph,
      currentNodeId: 'opener',
      isInteractive: true,
    );

    ensureThread(witnessThread);

    if (fromColdLoad) return;

    final systemMsgs = tData['systemMessages'] as Map<String, dynamic>? ?? {};
    await deliverNpcMessage(
      'tomasz',
      systemMsgs['initial_warning'] ?? 'Wiem że masz jej telefon. Widziałem światło w jej oknie wczoraj wieczorem — ktoś tam był. To nie była ona. Jeśli znasz hasło, napisz. Jeśli nie — schowaj telefon i uciekaj.',
      delay: const Duration(seconds: 3),
    );
  }

  /// Chapter 3 hook — adds the prosecutor (Prokurator R.) thread,
  /// gated behind one of the redaction-decoded passwords. Two
  /// branches lead to two endings:
  /// - public testimony → ŚWIADEK
  /// - anonymous deposit → CIEŃ
  Future<void> triggerProsecutorDialog({bool fromColdLoad = false}) async {
    final dialogues = L10nService.instance.dialogues['threads'] as Map<String, dynamic>? ?? {};
    final pData = dialogues['prokurator'] ?? {};
    final pNodes = pData['nodes'] as Map<String, dynamic>? ?? {};

    final graph = _buildGraphFromData(pNodes);

    final prosecutorThread = ChatThread(
      id: 'prokurator',
      contactName: pData['contactName'] ?? 'Prokurator R. (centralna)',
      avatarColor: 0xFF34C759,
      messages: [],
      dialogueGraph: graph,
      currentNodeId: 'opener',
      isInteractive: true,
    );

    ensureThread(prosecutorThread);

    if (fromColdLoad) return;

    final systemMsgs = pData['systemMessages'] as Map<String, dynamic>? ?? {};
    await deliverNpcMessage(
      'prokurator',
      systemMsgs['initial_warning'] ?? 'Tu prokurator R. z Wydziału Spraw Wewnętrznych. Tomasz W. przekazał Pana dane. Mamy chwilę — proszę powiedzieć, jak chce Pan to rozegrać.',
      delay: const Duration(seconds: 3),
    );
  }

  /// Schedules an NPC line on a thread without requiring the player to be
  /// inside that chat.
  Future<void> deliverNpcMessage(
    String threadId,
    String text, {
    Duration delay = _typingDelay,
  }) async {
    final sessionId = _gameSessionId;
    // Auto-create thread if it doesn't exist (e.g. stalker, scheduled).
    if (!_threads.containsKey(threadId)) {
      String name;
      int? color;
      switch (threadId) {
        case 'stalker':
          name = '+48 *** *** ***';
          color = 0xFF000000;
        case 'n_scheduled':
          name = 'N. (zaplanowana)';
          color = 0xFFE08AB0;
        default:
          name = threadId;
      }
      _threads[threadId] = ChatThread(
        id: threadId,
        contactName: name,
        avatarColor: color,
        messages: [],
        isInteractive: false,
      );
    }

    final thread = _threads[threadId]!;

    // Prevent consecutive duplicate messages from the same sender in the same thread.
    if (thread.messages.isNotEmpty) {
      final last = thread.messages.last;
      if (last.sender == MessageSender.npc && last.text == text) {
        return;
      }
    }

    if (_activeThreadId == threadId) {
      _isNpcTyping = true;
      _typingThreadId = threadId;
      notifyListeners();
    }

    await wait(delay, sessionId: sessionId);
    if (sessionId != _gameSessionId) return;

    thread.messages.add(ChatMessage(
      sender: MessageSender.npc,
      text: text,
      timestamp: DateTime.now(),
    ));

    if (_activeThreadId != threadId) {
      thread.unreadCount += 1;
      _raiseBanner(thread, text);
    }

    if (_typingThreadId == threadId) {
      _isNpcTyping = false;
      _typingThreadId = null;
    }
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

  Future<void> _wait(Duration duration, int sessionId) async {
    var remaining = duration;
    while (remaining > Duration.zero) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (sessionId != _gameSessionId) return;
      if (!_isPaused) {
        remaining -= const Duration(milliseconds: 200);
      }
    }
  }

  // ---------- Internals ----------

  Future<void> _runNode(ChatThread thread, String nodeId, int sessionId) async {
    final graph = thread.dialogueGraph;
    if (graph == null) return;
    final node = graph[nodeId];
    if (node == null) return;

    thread.currentNodeId = nodeId;

    for (final line in node.npcMessages) {
      // Breathing delay between messages or before the first message
      await _wait(const Duration(milliseconds: 1200), sessionId);
      if (sessionId != _gameSessionId) return;

      _isNpcTyping = true;
      _typingThreadId = thread.id;
      notifyListeners();

      await _wait(_typingDelayForText(line), sessionId);
      if (sessionId != _gameSessionId) return;

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
      _typingThreadId = null;
      _save();
      notifyListeners();
    }

    final auto = node.autoNextNodeId;
    if (auto != null) {
      await _runNode(thread, auto, sessionId);
      return;
    }

    // Ending fires after the last npc line in this node has been seen.
    final endingId = node.triggersEndingId;
    if (endingId != null) {
      await _wait(_endingDelay, sessionId);
      if (sessionId != _gameSessionId) return;
      onEndingTriggered?.call(endingId);
    }

    // Journalist hook — opens the path to the TRUTH ending.
    if (node.triggersJournalistHook) {
      await _wait(const Duration(seconds: 2), sessionId);
      if (sessionId != _gameSessionId) return;
      onJournalistHookTriggered?.call();
    }
  }

  // ---------- Reset ----------

  void reset() {
    _gameSessionId++;
    _threads.clear();
    _activeThreadId = null;
    _isNpcTyping = false;
    _isProcessingChoice = false;
    _typingThreadId = null;
    _seed();
    _save();
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
    final dialogues = L10nService.instance.dialogues['threads'] as Map<String, dynamic>? ?? {};

    // Helper to get thread data from JSON
    Map<String, dynamic> getThreadData(String id) => dialogues[id] ?? {};

    // 1. Mama
    final mamaData = getThreadData('mama');
    final mamaMsgs = (mamaData['messages'] as List? ?? []);
    final mamaNodes = (mamaData['nodes'] as Map<String, dynamic>? ?? {});

    final mama = ChatThread(
      id: 'mama',
      contactName: mamaData['contactName'] ?? 'Mama',
      avatarColor: 0xFFE08AB0,
      messages: [], // Start empty for a fresh feel
      isInteractive: true,
      dialogueGraph: _buildGraphFromData(mamaNodes),
      currentNodeId: 'respond',
    );

    // 2. Nieznany
    final nData = getThreadData('nieznany');
    final nMsgs = (nData['messages'] as List? ?? []);
    final nNodes = (nData['nodes'] as Map<String, dynamic>? ?? {});

    final nieznany = ChatThread(
      id: 'nieznany',
      contactName: nData['contactName'] ?? 'Nieznany',
      avatarColor: 0xFF3A3A3C,
      messages: [], // Start empty for arrival logic
      dialogueGraph: _buildGraphFromData(nNodes),
      currentNodeId: 'intro',
      unreadCount: 0,
      isInteractive: true,
    );

    // 3. Dziennikarka
    final dData = getThreadData('dziennikarka');
    final dMsgs = (dData['messages'] as List? ?? []);

    final dziennikarka = ChatThread(
      id: 'dziennikarka',
      contactName: dData['contactName'] ?? 'Anita Z. (Gazeta)',
      avatarColor: 0xFFFFCC00,
      messages: [], // Start empty
      isInteractive: false,
    );

    _threads[mama.id] = mama;
    _threads[nieznany.id] = nieznany;
    _threads[dziennikarka.id] = dziennikarka;
  }

  Map<String, DialogueNode> _buildGraphFromData(Map<String, dynamic> data) {
    final graph = <String, DialogueNode>{};
    data.forEach((id, nodeData) {
      final npcMsgs = (nodeData['npcMessages'] as List? ?? []).cast<String>();
      final choicesData = (nodeData['choices'] as List? ?? []);
      final choices = choicesData.map((c) {
        return DialogueChoice(
          text: c['text'] as String,
          nextNodeId: c['nextNodeId'] as String,
          trustDeltas: (c['trustDeltas'] as Map? ?? {}).cast<String, int>(),
          requiresMinTrust: (c['requiresMinTrust'] as Map? ?? {}).cast<String, int>(),
          requiresMinEvidence: c['requiresMinEvidence'] as int?,
          requiresFlag: c['requiresFlag'] as String?,
          hidden: c['hidden'] as bool? ?? false,
          lockedReasonKey: c['lockedReasonKey'] as String?,
        );
      }).toList();

      graph[id] = DialogueNode(
        id: id,
        npcMessages: npcMsgs,
        choices: choices,
        autoNextNodeId: nodeData['autoNextNodeId'] as String?,
        triggersEndingId: nodeData['triggersEndingId'] as String?,
        triggersJournalistHook: nodeData['triggersJournalistHook'] as bool? ?? false,
      );
    });
    return graph;
  }
}
