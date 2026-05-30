import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/flags_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('FlagsState', () {
    test('starts empty', () {
      final s = FlagsState(persistence: PersistenceService.instance);
      expect(s.isSet('anything'), isFalse);
      expect(s.snapshot(), isEmpty);
    });

    test('set adds and notifies', () {
      final s = FlagsState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.set('puzzle.email_recovered');
      expect(s.isSet('puzzle.email_recovered'), isTrue);
      expect(notifications, 1);
    });

    test('set is idempotent', () {
      final s = FlagsState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.set('puzzle.x');
      s.set('puzzle.x');
      s.set('puzzle.x');
      expect(notifications, 1);
    });

    test('unset removes and notifies', () {
      final s = FlagsState(persistence: PersistenceService.instance);
      s.set('puzzle.x');
      var notifications = 0;
      s.addListener(() => notifications++);

      s.unset('puzzle.x');
      expect(s.isSet('puzzle.x'), isFalse);
      expect(notifications, 1);

      // unset of unset flag — no-op
      s.unset('puzzle.x');
      expect(notifications, 1);
    });

    test('cold-load restores flags', () {
      final s1 = FlagsState(persistence: PersistenceService.instance);
      s1.set('puzzle.email_recovered');
      s1.set('puzzle.voices_matched');

      final s2 = FlagsState(persistence: PersistenceService.instance);
      expect(s2.isSet('puzzle.email_recovered'), isTrue);
      expect(s2.isSet('puzzle.voices_matched'), isTrue);
      expect(s2.snapshot(),
          {'puzzle.email_recovered', 'puzzle.voices_matched'});
    });

    test('reset wipes flags', () {
      final s = FlagsState(persistence: PersistenceService.instance);
      s.set('a');
      s.set('b');
      s.reset();
      expect(s.snapshot(), isEmpty);
    });
  });
}
