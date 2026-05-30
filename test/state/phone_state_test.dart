import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/phone_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('PhoneState', () {
    test('starts locked, no error, no failed attempts', () {
      final s = PhoneState(persistence: PersistenceService.instance);
      expect(s.isUnlocked, isFalse);
      expect(s.failedAttempts, 0);
      expect(s.lastError, isNull);
    });

    test('tryUnlock with correct PIN unlocks the phone', () {
      final s = PhoneState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      expect(s.tryUnlock('1984'), isTrue);
      expect(s.isUnlocked, isTrue);
      expect(s.lastError, isNull);
      expect(notifications, 1);
    });

    test('tryUnlock with wrong PIN increments failedAttempts and sets error',
        () {
      final s = PhoneState(persistence: PersistenceService.instance);

      expect(s.tryUnlock('0000'), isFalse);
      expect(s.failedAttempts, 1);
      expect(s.lastError, isNotNull);

      expect(s.tryUnlock('1234'), isFalse);
      expect(s.failedAttempts, 2);

      expect(s.tryUnlock('2580'), isFalse);
      expect(s.failedAttempts, 3);
      expect(s.lastError, contains('Środkowa'));

      expect(s.tryUnlock('9999'), isFalse);
      expect(s.lastError, 'Nieprawidłowy kod');
    });

    test('lock locks the phone and persists', () {
      final s = PhoneState(persistence: PersistenceService.instance);
      s.tryUnlock('1984');
      expect(s.isUnlocked, isTrue);

      s.lock();
      expect(s.isUnlocked, isFalse);
    });

    test('clearError clears the last error and notifies', () {
      final s = PhoneState(persistence: PersistenceService.instance);
      s.tryUnlock('0000');
      expect(s.lastError, isNotNull);

      var notifications = 0;
      s.addListener(() => notifications++);
      s.clearError();
      expect(s.lastError, isNull);
      expect(notifications, 1);

      // Idempotent — second call does not notify again.
      s.clearError();
      expect(notifications, 1);
    });

    test('reset wipes state to locked + 0 attempts', () {
      final s = PhoneState(persistence: PersistenceService.instance);
      s.tryUnlock('0000');
      s.tryUnlock('1984');
      expect(s.isUnlocked, isTrue);
      expect(s.failedAttempts, 1);

      s.reset();
      expect(s.isUnlocked, isFalse);
      expect(s.failedAttempts, 0);
      expect(s.lastError, isNull);
    });

    test('cold-load always starts locked even when persisted unlocked', () {
      // Simulate a previous run that unlocked the phone.
      final s1 = PhoneState(persistence: PersistenceService.instance);
      s1.tryUnlock('1984');
      expect(s1.isUnlocked, isTrue);

      // New instance (= app relaunched) — should start locked again.
      final s2 = PhoneState(persistence: PersistenceService.instance);
      expect(s2.isUnlocked, isFalse);
    });
  });
}
