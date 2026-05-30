import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/trust_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('TrustState', () {
    test('all NPCs start at 0', () {
      final s = TrustState(persistence: PersistenceService.instance);
      for (final id in TrustState.trackedNpcs) {
        expect(s.get(id), 0);
      }
    });

    test('unknown NPC returns 0', () {
      final s = TrustState(persistence: PersistenceService.instance);
      expect(s.get('santa'), 0);
    });

    test('apply increments and notifies', () {
      final s = TrustState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.apply({'mama': 10, 'anita': -5});
      expect(s.get('mama'), 10);
      expect(s.get('anita'), -5);
      expect(notifications, 1);
    });

    test('apply clamps to [-100, +100]', () {
      final s = TrustState(persistence: PersistenceService.instance);
      s.apply({'mama': 200});
      expect(s.get('mama'), 100);

      s.apply({'mama': -300});
      expect(s.get('mama'), -100);
    });

    test('apply with zero deltas does not notify', () {
      final s = TrustState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.apply({'mama': 0, 'anita': 0});
      expect(notifications, 0);
    });

    test('apply with empty map is no-op', () {
      final s = TrustState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.apply({});
      expect(notifications, 0);
    });

    test('meets returns true when threshold reached', () {
      final s = TrustState(persistence: PersistenceService.instance);
      s.apply({'anita': 30});
      expect(s.meets('anita', 30), isTrue);
      expect(s.meets('anita', 31), isFalse);
      expect(s.meets('anita', 0), isTrue);
    });

    test('allBelow returns true when every tracked NPC < threshold', () {
      final s = TrustState(persistence: PersistenceService.instance);
      // All at 0 — below 1.
      expect(s.allBelow(1), isTrue);
      expect(s.allBelow(0), isFalse);

      s.apply({'mama': 50});
      expect(s.allBelow(40), isFalse);
      expect(s.allBelow(60), isTrue);
    });

    test('cold-load restores values', () {
      final s1 = TrustState(persistence: PersistenceService.instance);
      s1.apply({'mama': 25, 'tomasz': -40});

      final s2 = TrustState(persistence: PersistenceService.instance);
      expect(s2.get('mama'), 25);
      expect(s2.get('tomasz'), -40);
      expect(s2.get('anita'), 0);
    });

    test('reset wipes all values (in-memory)', () {
      final s = TrustState(persistence: PersistenceService.instance);
      s.apply({'mama': 50});
      s.reset();
      expect(s.get('mama'), 0);
    });

    test('snapshot is unmodifiable', () {
      final s = TrustState(persistence: PersistenceService.instance);
      s.apply({'mama': 10});
      final snap = s.snapshot();
      expect(() => snap['mama'] = 99, throwsUnsupportedError);
    });

    test('apply is incremental (delta semantics)', () {
      final s = TrustState(persistence: PersistenceService.instance);
      s.apply({'mama': 30});
      s.apply({'mama': -10});
      s.apply({'mama': 5});
      expect(s.get('mama'), 25);
    });
  });
}
