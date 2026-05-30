import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/notes_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('NotesState', () {
    test('seeded notes include locked secret and plan_b', () {
      final s = NotesState(persistence: PersistenceService.instance);
      final secret = s.noteById('secret');
      final planB = s.noteById('plan_b');
      expect(secret, isNotNull);
      expect(planB, isNotNull);
      expect(secret!.isLocked, isTrue);
      expect(planB!.isLocked, isTrue);
      expect(s.hasUnlockedSecret, isFalse);
    });

    test('tryUnlock with correct PIN unlocks the secret note + fires hook',
        () {
      final s = NotesState(persistence: PersistenceService.instance);

      String? hookId;
      bool? hookFromCold;
      s.onLockedNoteUnlocked = (id, {fromColdLoad = false}) {
        hookId = id;
        hookFromCold = fromColdLoad;
      };

      expect(s.tryUnlock('secret', '7309'), isTrue);
      expect(s.noteById('secret')!.isLocked, isFalse);
      expect(s.hasUnlockedSecret, isTrue);
      expect(hookId, 'secret');
      expect(hookFromCold, isFalse);
    });

    test('tryUnlock with wrong PIN does not unlock and does not fire hook',
        () {
      final s = NotesState(persistence: PersistenceService.instance);
      var hookFired = false;
      s.onLockedNoteUnlocked = (_, {fromColdLoad = false}) => hookFired = true;

      expect(s.tryUnlock('secret', '0000'), isFalse);
      expect(s.noteById('secret')!.isLocked, isTrue);
      expect(s.hasUnlockedSecret, isFalse);
      expect(hookFired, isFalse);
    });

    test('hook fires only once even on repeated unlock attempts', () {
      final s = NotesState(persistence: PersistenceService.instance);
      var hookCount = 0;
      s.onLockedNoteUnlocked = (_, {fromColdLoad = false}) => hookCount++;

      s.tryUnlock('secret', '7309');
      // Second call returns false — note already unlocked.
      expect(s.tryUnlock('secret', '7309'), isFalse);
      expect(hookCount, 1);
    });

    test('plan_b unlock fires hook with correct id', () {
      final s = NotesState(persistence: PersistenceService.instance);
      String? hookId;
      s.onLockedNoteUnlocked = (id, {fromColdLoad = false}) => hookId = id;

      expect(s.tryUnlock('plan_b', '1422'), isTrue);
      expect(hookId, 'plan_b');
    });

    test('cold-load: previously unlocked notes stay unlocked', () async {
      final s1 = NotesState(persistence: PersistenceService.instance);
      s1.tryUnlock('secret', '7309');
      expect(s1.hasUnlockedSecret, isTrue);

      // Simulate app relaunch.
      final s2 = NotesState(persistence: PersistenceService.instance);
      expect(s2.noteById('secret')!.isLocked, isFalse);
      expect(s2.hasUnlockedSecret, isTrue);
    });

    test('replayHookForColdLoad fires with fromColdLoad=true', () {
      final s1 = NotesState(persistence: PersistenceService.instance);
      s1.tryUnlock('secret', '7309');

      final s2 = NotesState(persistence: PersistenceService.instance);
      String? hookId;
      bool? hookFromCold;
      s2.onLockedNoteUnlocked = (id, {fromColdLoad = false}) {
        hookId = id;
        hookFromCold = fromColdLoad;
      };
      s2.replayHookForColdLoad();
      expect(hookId, 'secret');
      expect(hookFromCold, isTrue);
    });

    test('replayHookForColdLoad does nothing if secret was never unlocked',
        () {
      final s = NotesState(persistence: PersistenceService.instance);
      var fired = false;
      s.onLockedNoteUnlocked = (_, {fromColdLoad = false}) => fired = true;
      s.replayHookForColdLoad();
      expect(fired, isFalse);
    });

    test('reset wipes unlocked state and re-seeds locked notes', () {
      final s = NotesState(persistence: PersistenceService.instance);
      s.tryUnlock('secret', '7309');
      s.tryUnlock('plan_b', '1422');
      expect(s.noteById('secret')!.isLocked, isFalse);

      s.reset();
      expect(s.noteById('secret')!.isLocked, isTrue);
      expect(s.noteById('plan_b')!.isLocked, isTrue);
      expect(s.hasUnlockedSecret, isFalse);
    });
  });
}
