import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/maps_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('MapsState — basic', () {
    test('seeds pins and identifies route subset', () {
      final s = MapsState(persistence: PersistenceService.instance);
      expect(s.pins.length, greaterThanOrEqualTo(5));
      expect(s.routePins.map((p) => p.id),
          equals(MapsState.routePinIds));
    });

    test('correctOrder is sorted by timestamp ascending', () {
      final s = MapsState(persistence: PersistenceService.instance);
      final order = s.correctOrder;
      expect(order, [
        'home',
        'work',
        'cafe_relaks',
        'parking_hipermarket',
        'las_kabacki',
      ]);
    });
  });

  group('MapsState — puzzle', () {
    test('starts unsolved with empty player order', () {
      final s = MapsState(persistence: PersistenceService.instance);
      expect(s.playerOrder, isEmpty);
      expect(s.isPuzzleSolved, isFalse);
    });

    test('partial order does not solve', () {
      final s = MapsState(persistence: PersistenceService.instance);
      s.setPlayerOrder(['home', 'work']);
      expect(s.isPuzzleSolved, isFalse);
    });

    test('correct order solves and fires hook', () {
      final s = MapsState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onPuzzleSolved = () => fireCount++;

      s.setPlayerOrder(s.correctOrder);
      expect(s.isPuzzleSolved, isTrue);
      expect(fireCount, 1);

      // Re-setting the same order does not re-fire.
      s.setPlayerOrder(s.correctOrder);
      expect(fireCount, 1);
    });

    test('wrong order with same length is unsolved', () {
      final s = MapsState(persistence: PersistenceService.instance);
      // Reverse it
      s.setPlayerOrder(s.correctOrder.reversed.toList());
      expect(s.isPuzzleSolved, isFalse);
    });

    test('togglePin adds and removes', () {
      final s = MapsState(persistence: PersistenceService.instance);
      s.togglePin('home');
      expect(s.playerOrder, ['home']);
      s.togglePin('work');
      expect(s.playerOrder, ['home', 'work']);
      s.togglePin('home'); // remove
      expect(s.playerOrder, ['work']);
    });

    test('togglePin ignores non-route pins', () {
      final s = MapsState(persistence: PersistenceService.instance);
      s.togglePin('plac_zbawiciela');
      expect(s.playerOrder, isEmpty);
    });

    test('movePin reorders', () {
      final s = MapsState(persistence: PersistenceService.instance);
      s.setPlayerOrder(['home', 'work', 'cafe_relaks']);
      s.movePin('cafe_relaks', 0);
      expect(s.playerOrder, ['cafe_relaks', 'home', 'work']);
    });

    test('cold-load preserves order + solved state', () {
      final s1 = MapsState(persistence: PersistenceService.instance);
      s1.setPlayerOrder(s1.correctOrder);
      expect(s1.isPuzzleSolved, isTrue);

      final s2 = MapsState(persistence: PersistenceService.instance);
      expect(s2.playerOrder, s1.correctOrder);
      expect(s2.isPuzzleSolved, isTrue);
    });

    test('reset wipes order + solved', () {
      final s = MapsState(persistence: PersistenceService.instance);
      s.setPlayerOrder(s.correctOrder);
      s.reset();
      expect(s.playerOrder, isEmpty);
      expect(s.isPuzzleSolved, isFalse);
    });
  });
}
