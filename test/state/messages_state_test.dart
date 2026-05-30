import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/messages_state.dart';
import 'package:zaginiona/state/notifications_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('MessagesState — seeding', () {
    test('seeds mama, nieznany and dziennikarka threads', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      expect(s.threadById('mama'), isNotNull);
      expect(s.threadById('nieznany'), isNotNull);
      expect(s.threadById('dziennikarka'), isNotNull);
    });

    test('nieznany thread starts unread, interactive, with intro line', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      final n = s.threadById('nieznany')!;
      expect(n.unreadCount, 1);
      expect(n.isInteractive, isTrue);
      expect(n.currentNodeId, 'intro');
      expect(n.messages, hasLength(1));
    });

    test('totalUnread aggregates across threads', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      // Only nieznany is seeded with unread = 1.
      expect(s.totalUnread, greaterThanOrEqualTo(1));
    });
  });

  group('MessagesState — openThread / closeThread', () {
    test('openThread clears unreadCount on the opened thread', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      expect(s.threadById('nieznany')!.unreadCount, 1);
      s.openThread('nieznany');
      expect(s.threadById('nieznany')!.unreadCount, 0);
      expect(s.activeThread?.id, 'nieznany');
    });

    test('closeThread clears activeThread', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.openThread('nieznany');
      s.closeThread();
      expect(s.activeThread, isNull);
    });
  });

  group('MessagesState — currentChoices', () {
    test('returns intro choices for nieznany when active', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.openThread('nieznany');
      final choices = s.currentChoices;
      expect(choices, hasLength(2));
    });

    test('returns empty list when no active thread', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      expect(s.currentChoices, isEmpty);
    });
  });

  group('MessagesState — selectChoice', () {
    test('appends player message and runs node lines (with fake async)', () {
      fakeAsync((async) {
        final s = MessagesState(persistence: PersistenceService.instance);
        s.attachNotifications(NotificationsState());
        s.openThread('nieznany');

        final intro = s.currentChoices;
        expect(intro, hasLength(2));

        // Pick the first choice — leads to branch_a.
        s.selectChoice(intro.first);

        // Player message added immediately, NPC line is delayed.
        async.flushMicrotasks();
        final t = s.threadById('nieznany')!;
        expect(t.messages.last.text, intro.first.text);

        // Advance through typing delays + chained autoNext nodes.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        // Should now be sitting on hint_files (terminal node) with no choices.
        expect(t.currentNodeId, 'hint_files');
        expect(s.hasCompletedIntro, isTrue);
      });
    });

    test('selectChoice with no active thread is a no-op', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.attachNotifications(NotificationsState());
      // No openThread.
      const choice = DialogueChoice(text: 'x', nextNodeId: 'y');
      // Should not throw.
      expect(() => s.selectChoice(choice), returnsNormally);
    });
  });

  group('MessagesState — ensureThread', () {
    test('inserts new thread when missing', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      expect(s.threadById('szeryf'), isNull);
      s.ensureThread(ChatThread(
        id: 'szeryf',
        contactName: 'Szeryf',
        messages: [],
        isInteractive: true,
      ));
      expect(s.threadById('szeryf'), isNotNull);
    });

    test('restores dialogue graph on existing graphless thread', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.ensureThread(ChatThread(
        id: 'szeryf',
        contactName: 'Szeryf',
        messages: [],
        isInteractive: false,
      ));
      // Now ensure with a full graph — should upgrade.
      s.ensureThread(ChatThread(
        id: 'szeryf',
        contactName: 'Szeryf',
        messages: [],
        dialogueGraph: const {
          'opener': DialogueNode(id: 'opener'),
        },
        currentNodeId: 'opener',
        isInteractive: true,
      ));
      final t = s.threadById('szeryf')!;
      expect(t.isInteractive, isTrue);
      expect(t.dialogueGraph, isNotNull);
      expect(t.currentNodeId, 'opener');
    });
  });

  group('MessagesState — persistence + cold load', () {
    test('persists thread state and restores it on new instance', () {
      final s1 = MessagesState(persistence: PersistenceService.instance);
      s1.openThread('nieznany');
      // openThread clears unread and triggers _save.
      expect(s1.threadById('nieznany')!.unreadCount, 0);

      final s2 = MessagesState(persistence: PersistenceService.instance);
      expect(s2.threadById('nieznany')!.unreadCount, 0);
    });
  });

  group('MessagesState — reset', () {
    test('reset re-seeds initial threads and clears active', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.openThread('nieznany');
      s.reset();
      expect(s.activeThread, isNull);
      expect(s.threadById('nieznany'), isNotNull);
      expect(s.threadById('nieznany')!.unreadCount, 1);
    });
  });


  group('MessagesState — dialogue gating', () {
    test('gatedChoices reflects all choices when no evaluator wired', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.openThread('nieznany');
      // Without an evaluator every choice is treated as available.
      final gated = s.gatedChoices;
      expect(gated, hasLength(2));
      for (final g in gated) {
        expect(g.isAvailable, isTrue);
      }
    });

    test('gatedChoices marks choices unavailable per evaluator', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.attachGateEvaluator((c) => false); // block everything
      s.openThread('nieznany');
      final gated = s.gatedChoices;
      // Choices are not hidden by default — they remain visible but locked.
      expect(gated, hasLength(2));
      for (final g in gated) {
        expect(g.isAvailable, isFalse);
        expect(g.isVisibleButLocked, isTrue);
      }
    });

    test('selectChoice refuses gated-out choices', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      s.attachGateEvaluator((c) => false);
      s.openThread('nieznany');
      final n = s.threadById('nieznany')!;
      final lengthBefore = n.messages.length;

      final blocked = s.currentChoices.first;
      // ignore: discarded_futures
      s.selectChoice(blocked);
      // Player message should NOT have been added.
      expect(n.messages.length, lengthBefore);
    });

    test('selectChoice forwards trustDeltas to attached sink', () {
      final s = MessagesState(persistence: PersistenceService.instance);
      Map<String, int>? captured;
      s.attachTrustSink((d) => captured = d);
      s.openThread('nieznany');

      // Pick the first intro choice; in our seed it has no deltas, but
      // we add a custom thread to verify forwarding.
      final synth = ChatThread(
        id: 'synth',
        contactName: 'Synth',
        messages: [],
        dialogueGraph: const {
          'a': DialogueNode(
            id: 'a',
            choices: [
              DialogueChoice(
                text: 'go',
                nextNodeId: 'b',
                trustDeltas: {'mama': 5, 'anita': -3},
              ),
            ],
          ),
          'b': DialogueNode(id: 'b'),
        },
        currentNodeId: 'a',
        isInteractive: true,
      );
      s.ensureThread(synth);
      s.openThread('synth');
      final choice = s.currentChoices.single;
      // ignore: discarded_futures
      s.selectChoice(choice);
      expect(captured, {'mama': 5, 'anita': -3});
    });
  });
}