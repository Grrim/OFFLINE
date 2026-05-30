import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/signal_puzzle_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('SignalPuzzleState', () {
    test('starts undecoded with 0 attempts', () {
      final s = SignalPuzzleState(persistence: PersistenceService.instance);
      expect(s.isDecoded, isFalse);
      expect(s.failedAttempts, 0);
    });

    test('correct password decodes + fires hook', () {
      final s = SignalPuzzleState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onDecoded = () => fireCount++;

      expect(s.tryDecode('koperta1422'), isTrue);
      expect(s.isDecoded, isTrue);
      expect(fireCount, 1);

      // Idempotent.
      expect(s.tryDecode('koperta1422'), isTrue);
      expect(fireCount, 1);
    });

    test('case-insensitive + trims whitespace', () {
      final s = SignalPuzzleState(persistence: PersistenceService.instance);
      expect(s.tryDecode('  Koperta1422 '), isTrue);
    });

    test('wrong password increments attempts', () {
      final s = SignalPuzzleState(persistence: PersistenceService.instance);
      expect(s.tryDecode('wrong'), isFalse);
      expect(s.failedAttempts, 1);
      expect(s.tryDecode('also wrong'), isFalse);
      expect(s.failedAttempts, 2);
      expect(s.isDecoded, isFalse);
    });

    test('cold-load preserves decoded', () {
      final s1 = SignalPuzzleState(persistence: PersistenceService.instance);
      s1.tryDecode('koperta1422');

      final s2 = SignalPuzzleState(persistence: PersistenceService.instance);
      expect(s2.isDecoded, isTrue);
    });

    test('reset wipes', () {
      final s = SignalPuzzleState(persistence: PersistenceService.instance);
      s.tryDecode('koperta1422');
      s.reset();
      expect(s.isDecoded, isFalse);
    });
  });
}
