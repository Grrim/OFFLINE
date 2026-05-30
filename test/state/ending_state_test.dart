import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/ending_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('EndingState', () {
    test('catalog includes all nine endings', () {
      expect(EndingState.catalog.keys, containsAll([
        'caught', 'escape', 'truth', 'dawn',
        'corruption', 'solitude', 'cycle',
        'witness', 'shadow',
      ]));
    });

    test('cycle ending is marked secret', () {
      expect(EndingState.catalog['cycle']!.secret, isTrue);
    });

    test('starts with no active ending', () {
      final s = EndingState(persistence: PersistenceService.instance);
      expect(s.activeEnding, isNull);
    });

    test('trigger sets activeEnding and notifies', () {
      final s = EndingState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.trigger('truth');
      expect(s.activeEnding?.id, 'truth');
      expect(s.activeEnding?.title, 'PRAWDA');
      expect(notifications, 1);
    });

    test('trigger with unknown id is a no-op', () {
      final s = EndingState(persistence: PersistenceService.instance);
      s.trigger('does_not_exist');
      expect(s.activeEnding, isNull);
    });

    test('cold-load restores the persisted active ending', () {
      final s1 = EndingState(persistence: PersistenceService.instance);
      s1.trigger('dawn');
      expect(s1.activeEnding?.id, 'dawn');

      final s2 = EndingState(persistence: PersistenceService.instance);
      expect(s2.activeEnding?.id, 'dawn');
    });

    test('reset clears activeEnding (in-memory only)', () {
      final s = EndingState(persistence: PersistenceService.instance);
      s.trigger('caught');
      s.reset();
      expect(s.activeEnding, isNull);
    });

    test('every ending has non-empty title, subtitle and epilogue', () {
      for (final e in EndingState.catalog.values) {
        expect(e.title, isNotEmpty);
        expect(e.subtitle, isNotEmpty);
        expect(e.epilogue, isNotEmpty);
      }
    });
  });

  group('EndingState — discovery tracking', () {
    test('starts empty', () {
      final s = EndingState(persistence: PersistenceService.instance);
      expect(s.hasAnyDiscovered, isFalse);
      expect(s.discoveredEndings, isEmpty);
    });

    test('trigger marks ending discovered', () {
      final s = EndingState(persistence: PersistenceService.instance);
      s.trigger('truth');
      expect(s.hasAnyDiscovered, isTrue);
      expect(s.isDiscovered('truth'), isTrue);
      expect(s.isDiscovered('caught'), isFalse);
    });

    test('multiple triggers across runs accumulate discoveries', () {
      final s1 = EndingState(persistence: PersistenceService.instance);
      s1.trigger('truth');
      s1.reset(); // simulate "play again"
      s1.trigger('caught');

      final s2 = EndingState(persistence: PersistenceService.instance);
      expect(s2.discoveredEndings, containsAll(['truth', 'caught']));
    });

    test('reset preserves discovery, resetDiscoveryToo wipes', () {
      final s = EndingState(persistence: PersistenceService.instance);
      s.trigger('dawn');
      s.reset();
      expect(s.isDiscovered('dawn'), isTrue);
      s.resetDiscoveryToo();
      expect(s.isDiscovered('dawn'), isFalse);
      expect(s.activeEnding, isNull);
    });
  });
}
