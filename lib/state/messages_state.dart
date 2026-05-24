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

  /// Calculates a realistic typing delay based on message length.
  /// Short messages (~20 chars) get ~1.2s, long ones (~150 chars) get ~3s.
  static Duration _typingDelayForText(String text) {
    final chars = text.length.clamp(10, 200);
    final ms = 800 + (chars * 12); // 800ms base + 12ms per character
    return Duration(milliseconds: ms.clamp(1000, 3500));
  }

  static const String _kThreadProgress = 'messages.progress.v1';

  final PersistenceService? _persistence;
  final Map<String, ChatThread> _threads = {};
  String? _activeThreadId;
  bool _isNpcTyping = false;
  String? _typingThreadId;

  NotificationsState? _notifications;
  void Function(String threadId)? _bannerNavigator;

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

  /// True if NPC is typing specifically in the given thread.
  bool isTypingInThread(String threadId) =>
      _isNpcTyping && _typingThreadId == threadId;

  int get totalUnread =>
      _threads.values.fold(0, (acc, t) => acc + t.unreadCount);

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

  /// Upgrades Anita's thread to interactive with the TRUTH-path dialogue
  /// graph. Idempotent — safe to call on cold-load too.
  Future<void> triggerJournalistDialog({bool fromColdLoad = false}) async {
    final graph = <String, DialogueNode>{
      'opener': const DialogueNode(
        id: 'opener',
        choices: [
          DialogueChoice(
            text: 'Anita, to ja. N. zniknęła. Mam wszystkie jej dowody '
                'na Helion-Bud i komendanta. Bierzecie to?',
            nextNodeId: 'confirm',
          ),
          DialogueChoice(
            text: 'Anita, jesteś tam? Sprawa jest gorąca, mam mało czasu.',
            nextNodeId: 'confirm',
          ),
        ],
      ),
      'confirm': const DialogueNode(
        id: 'confirm',
        npcMessages: [
          'O Boże. Wiedziałam, że coś jej się stało.',
          'Wysyłaj wszystko co masz. Zdjęcia, notatki, nazwiska. Mam '
              'bezpieczny kanał.',
        ],
        choices: [
          DialogueChoice(
            text: 'Wysyłam: zdjęcie z lasu, notatka N., wzmianki '
                'o komendancie K. i Helion-Budzie.',
            nextNodeId: 'send',
          ),
        ],
      ),
      'send': const DialogueNode(
        id: 'send',
        npcMessages: [
          'Mam wszystko. Otwieram redaktora naczelnego.',
          'Idziemy na pierwszą stronę. Jutro o 6:00 trafia do druku.',
          'N. by była z ciebie dumna. Schowaj się gdzieś bezpiecznie '
              'do rana.',
        ],
        triggersEndingId: 'truth',
      ),
    };

    final journalistThread = ChatThread(
      id: 'dziennikarka',
      contactName: 'Anita Z. (Gazeta)',
      avatarColor: 0xFFFFCC00,
      messages: const [],
      dialogueGraph: graph,
      currentNodeId: 'opener',
      isInteractive: true,
    );

    ensureThread(journalistThread);

    if (fromColdLoad) return;

    // Deliver an opener from Anita — fast, urgent.
    await deliverNpcMessage(
      'dziennikarka',
      'Kto to?! Gdzie jest N.?! Masz jej telefon — powiedz mi co się stało!',
      delay: const Duration(seconds: 3),
    );
  }

  /// Chapter 2 hook — adds the Witness (Tomasz W.) thread with a
  /// dialogue graph leading to the DAWN ending. The witness is
  /// referenced in the second locked note ("Plan B").
  Future<void> triggerWitnessDialog({bool fromColdLoad = false}) async {
    final graph = <String, DialogueNode>{
      'opener': const DialogueNode(
        id: 'opener',
        choices: [
          DialogueChoice(
            text: 'Tomasz? Drzewo, które padło na dachu.',
            nextNodeId: 'recognise',
          ),
          DialogueChoice(
            text: 'Tomasz, mam telefon N. Coś jej się stało.',
            nextNodeId: 'cold_open',
          ),
        ],
      ),
      'cold_open': const DialogueNode(
        id: 'cold_open',
        npcMessages: [
          'Skąd to wiesz? Skąd masz jej numer?',
          'Zanim cokolwiek powiem, podaj mi hasło, które ze sobą '
              'ustaliliśmy. N. mówiła ci?',
        ],
        choices: [
          DialogueChoice(
            text: 'Drzewo, które padło na dachu.',
            nextNodeId: 'recognise',
          ),
          DialogueChoice(
            text: 'Nie znam żadnego hasła. Po prostu mi pomóż.',
            nextNodeId: 'reject',
          ),
        ],
      ),
      'reject': const DialogueNode(
        id: 'reject',
        npcMessages: [
          'To nie tak działa. Jeśli nie znasz hasła, nie znałeś N.',
          'Schowaj telefon. Jutro kup nową kartę i wyjedź z miasta.',
          'Powodzenia.',
        ],
        // Soft fail — no ending, but the witness vanishes from the chat.
      ),
      'recognise': const DialogueNode(
        id: 'recognise',
        npcMessages: [
          'Dobra. Czyli jednak.',
          'Słuchaj uważnie - mam wszystko. Nagrania, kopie faktur, '
              'zdjęcia. Wszystko, co zebrała plus to, co ja zebrałem '
              'przez 2 lata po tym jak mnie wyrzucili z HB.',
          'Jest tylko jedna ścieżka, która działa. Centralna komenda. '
              'Prokurator dyżurny. Nie powiatowa. Nie miejska. '
              'CENTRALNA.',
        ],
        choices: [
          DialogueChoice(
            text: 'Idę. Daj mi 2 godziny.',
            nextNodeId: 'commit',
          ),
          DialogueChoice(
            text: 'A jak komenda centralna też jest skompromitowana?',
            nextNodeId: 'doubt',
          ),
        ],
      ),
      'doubt': const DialogueNode(
        id: 'doubt',
        npcMessages: [
          'Nie jest. Sprawdziłem. K. nie ma tam żadnych powiązań.',
          'Poza tym nie masz innej opcji. Albo idziesz, albo to się '
              'wszystko rozejdzie po nas.',
        ],
        choices: [
          DialogueChoice(
            text: 'Dobra. Idę.',
            nextNodeId: 'commit',
          ),
        ],
      ),
      'commit': const DialogueNode(
        id: 'commit',
        npcMessages: [
          'Wyślij mi natychmiast wszystkie dowody przez Signal. Numer '
              'masz w jej notatce.',
          'Spotkamy się przed gmachem. Ja będę z dziennikarką.',
          '...',
          'Dzwoni do mnie prokurator. Mówi że właśnie dostał materiały '
              'mailowo. Idą.',
          'Udało się.',
        ],
        triggersEndingId: 'dawn',
      ),
    };

    final witnessThread = ChatThread(
      id: 'tomasz',
      contactName: 'T.W. (sąsiad)',
      avatarColor: 0xFF5AC8FA,
      messages: const [],
      dialogueGraph: graph,
      currentNodeId: 'opener',
      isInteractive: true,
    );

    ensureThread(witnessThread);

    if (fromColdLoad) return;

    await deliverNpcMessage(
      'tomasz',
      'Wiem że masz jej telefon. Widziałem światło w jej oknie wczoraj '
          'wieczorem — ktoś tam był. To nie była ona. '
          'Jeśli znasz hasło, napisz. Jeśli nie — schowaj telefon i uciekaj.',
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
    // Auto-create thread if it doesn't exist (e.g. stalker).
    if (!_threads.containsKey(threadId)) {
      _threads[threadId] = ChatThread(
        id: threadId,
        contactName: threadId == 'stalker' ? '+48 *** *** ***' : threadId,
        avatarColor: threadId == 'stalker' ? 0xFF000000 : null,
        messages: [],
        isInteractive: false,
      );
    }

    final thread = _threads[threadId]!;

    if (_activeThreadId == threadId) {
      _isNpcTyping = true;
      _typingThreadId = threadId;
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

  // ---------- Internals ----------

  Future<void> _runNode(ChatThread thread, String nodeId) async {
    final graph = thread.dialogueGraph;
    if (graph == null) return;
    final node = graph[nodeId];
    if (node == null) return;

    thread.currentNodeId = nodeId;

    for (final line in node.npcMessages) {
      _isNpcTyping = true;
      _typingThreadId = thread.id;
      notifyListeners();

      await Future.delayed(_typingDelayForText(line));

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
      await _runNode(thread, auto);
      return;
    }

    // Ending fires after the last npc line in this node has been seen.
    final endingId = node.triggersEndingId;
    if (endingId != null) {
      await Future.delayed(_endingDelay);
      onEndingTriggered?.call(endingId);
    }

    // Journalist hook — opens the path to the TRUTH ending.
    if (node.triggersJournalistHook) {
      await Future.delayed(const Duration(seconds: 2));
      onJournalistHookTriggered?.call();
    }
  }

  // ---------- Reset ----------

  void reset() {
    _threads.clear();
    _activeThreadId = null;
    _isNpcTyping = false;
    _typingThreadId = null;
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
          text: 'Pamiętasz, żeby wziąć leki na ciśnienie?',
          timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Mruczek znowu rozdrapał kanapę. Ten kot mnie wykończy.',
          timestamp: now.subtract(const Duration(days: 2, hours: 14)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Kochanie, Pani Halinka pytała o ciebie. Zadzwoń do niej '
              'jak będziesz miała chwilę.',
          timestamp: now.subtract(const Duration(days: 2, hours: 6)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Słyszałaś, że znowu coś robią w tym lesie za miastem? '
              'Babcia mówi, że hałasy w nocy. Ciężkie maszyny.',
          timestamp: now.subtract(const Duration(days: 1, hours: 20)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Czemu nie odpisujesz? Wszystko w porządku?',
          timestamp: now.subtract(const Duration(days: 1, hours: 12)),
        ),
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
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Dzwoniłam do twojego biura. Powiedzieli, że nie pojawiłaś '
              'się od piątku. Co się dzieje?',
          timestamp: now.subtract(const Duration(hours: 10)),
        ),
      ],
      isInteractive: true,
      dialogueGraph: {
        'respond': const DialogueNode(
          id: 'respond',
          choices: [
            DialogueChoice(
              text: 'Mamo, to nie N. Znalazłem jej telefon. Ona zniknęła.',
              nextNodeId: 'shock',
            ),
            DialogueChoice(
              text: 'Wszystko OK, nie martw się. Odezwę się później.',
              nextNodeId: 'lie',
            ),
          ],
        ),
        'shock': const DialogueNode(
          id: 'shock',
          npcMessages: [
            'Co?? Jak to zniknęła?! Kto to pisze?!',
            'Boże... Dzwonię na policję. Natychmiast.',
          ],
          choices: [
            DialogueChoice(
              text: 'NIE dzwoń na policję! Policja jest w to zamieszana!',
              nextNodeId: 'warning',
            ),
          ],
        ),
        'warning': const DialogueNode(
          id: 'warning',
          npcMessages: [
            'Co ty mówisz... Jak to zamieszana...',
            'Dobrze. Nie dzwonię. Ale powiedz mi co się dzieje.',
            'Błagam, powiedz mi że moja córka żyje.',
          ],
          choices: [
            DialogueChoice(
              text: 'Robię wszystko co mogę żeby ją znaleźć. Zaufaj mi.',
              nextNodeId: 'trust',
            ),
          ],
        ),
        'trust': const DialogueNode(
          id: 'trust',
          npcMessages: [
            'Dobrze... Dobrze. Ufam ci.',
            'Proszę, bądź ostrożny. Kimkolwiek jesteś.',
          ],
        ),
        'lie': const DialogueNode(
          id: 'lie',
          npcMessages: [
            'Kochanie? Czemu piszesz tak dziwnie?',
            'To nie brzmi jak ty. Co się dzieje?',
          ],
        ),
      },
      currentNodeId: 'respond',
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
        autoNextNodeId: 'hint_files',
      ),
      'hint_files': const DialogueNode(
        id: 'hint_files',
        npcMessages: [
          'Jeszcze jedno — w Plikach są dokumenty, które zebrała. Faktury, '
              'nagrania, lista koperty. Przeczytaj je. Zrozumiesz, z kim masz '
              'do czynienia.',
          'I nie próbuj dzwonić na policję z tego telefonu. Nie masz zasięgu. '
              'Zresztą... policja to część problemu.',
          'Teraz idź do Zdjęć. Znajdź to ciemne zdjęcie z lasu — zrobione '
              'wczoraj w nocy. Kliknij na nie i naciśnij przycisk Info na dole. '
              'Tam jest ukryty kod.',
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

    // Dziennikarka — quiet thread that becomes the player's lifeline
    // for the TRUTH ending. Her last message references Helion-Bud
    // before the player even knows what that is.
    final dziennikarka = ChatThread(
      id: 'dziennikarka',
      contactName: 'Anita Z. (Gazeta)',
      avatarColor: 0xFFFFCC00,
      messages: [
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Cześć N., mam materiał gotowy do publikacji. Brakuje mi '
              'tylko twojego zielonego światła i tych dokumentów co '
              'mówiłaś.',
          timestamp: now.subtract(const Duration(days: 4, hours: 3)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Redaktor naczelny się waha — boi się procesu od Helion-Bud. '
              'Daj mi cokolwiek czarno na białym i puszczamy to w sobotę.',
          timestamp: now.subtract(const Duration(days: 3, hours: 11)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'Jesteś?',
          timestamp: now.subtract(const Duration(days: 2, hours: 4)),
        ),
        ChatMessage(
          sender: MessageSender.npc,
          text: 'N., zaczynam się martwić. Odezwij się jak tylko możesz.',
          timestamp: now.subtract(const Duration(hours: 30)),
        ),
      ],
      isInteractive: false,
    );

    _threads[mama.id] = mama;
    _threads[nieznany.id] = nieznany;
    _threads[dziennikarka.id] = dziennikarka;

    // Stalker — anonymous threatening thread. Non-interactive.
    // Messages are delivered by timed hooks in main.dart.
    // NOT added to _threads yet — will appear only when first message arrives.
  }
}
