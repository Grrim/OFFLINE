import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/new_game_plus_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('NewGamePlusState', () {
    test('starts at run 0, plus inactive, no endings', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      expect(s.runCount, 0);
      expect(s.isPlusActive, isFalse);
      expect(s.previousEndings, isEmpty);
      expect(s.canStartPlus, isFalse);
      expect(s.cycleAvailable, isFalse);
    });

    test('recordEnding bumps run + appends', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.recordEnding('caught');
      expect(s.runCount, 1);
      expect(s.previousEndings, ['caught']);
      expect(s.canStartPlus, isTrue);

      s.recordEnding('truth');
      expect(s.runCount, 2);
      expect(s.previousEndings, ['caught', 'truth']);
    });

    test('recordEnding does not double-record same id back-to-back', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.recordEnding('caught');
      s.recordEnding('caught'); // same as last — ignored
      expect(s.runCount, 1);
    });

    test('enterPlusRun + leavePlusRun toggle flag', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.enterPlusRun();
      expect(s.isPlusActive, isTrue);
      s.leavePlusRun();
      expect(s.isPlusActive, isFalse);
    });

    test('cycleAvailable requires NG+ active + run>=2 + hinted', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.recordEnding('caught');
      s.recordEnding('truth');
      s.enterPlusRun();
      expect(s.cycleAvailable, isFalse, reason: 'not hinted yet');

      s.markCycleHinted();
      expect(s.cycleAvailable, isTrue);

      // Below threshold (runCount must be >=2).
      final s2 = NewGamePlusState(persistence: PersistenceService.instance);
      s2.resetAll();
      s2.recordEnding('caught');
      s2.enterPlusRun();
      s2.markCycleHinted();
      expect(s2.cycleAvailable, isFalse);
    });

    test('leavePlusRun clears cycleHinted', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.enterPlusRun();
      s.markCycleHinted();
      expect(s.cycleHinted, isTrue);
      s.leavePlusRun();
      expect(s.cycleHinted, isFalse);
      expect(s.isPlusActive, isFalse);
    });

    test('cold-load restores all fields', () {
      final s1 = NewGamePlusState(persistence: PersistenceService.instance);
      s1.recordEnding('truth');
      s1.recordEnding('dawn');
      s1.enterPlusRun();
      s1.markCycleHinted();

      final s2 = NewGamePlusState(persistence: PersistenceService.instance);
      expect(s2.runCount, 2);
      expect(s2.previousEndings, ['truth', 'dawn']);
      expect(s2.isPlusActive, isTrue);
      expect(s2.cycleHinted, isTrue);
      expect(s2.cycleAvailable, isTrue);
    });

    test('resetAll wipes everything', () {
      final s = NewGamePlusState(persistence: PersistenceService.instance);
      s.recordEnding('caught');
      s.enterPlusRun();
      s.markCycleHinted();
      s.resetAll();
      expect(s.runCount, 0);
      expect(s.isPlusActive, isFalse);
      expect(s.previousEndings, isEmpty);
      expect(s.cycleHinted, isFalse);
    });
  });
}
