import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/browser_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('BrowserState', () {
    test('seeded with multiple entries, none visited initially', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      expect(s.entries, isNotEmpty);
      for (final e in s.entries) {
        expect(s.hasVisited(e.id), isFalse);
      }
    });

    test('markVisited records visit', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      s.markVisited('krs_helion');
      expect(s.hasVisited('krs_helion'), isTrue);
    });

    test('markVisited is idempotent and does not double-notify', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.markVisited('krs_helion');
      s.markVisited('krs_helion');
      s.markVisited('krs_helion');
      expect(notifications, 1);
    });

    test('cold-load preserves visited ids', () {
      final s1 = BrowserState(persistence: PersistenceService.instance);
      s1.markVisited('krs_helion');
      s1.markVisited('forum_lokalny');

      final s2 = BrowserState(persistence: PersistenceService.instance);
      expect(s2.hasVisited('krs_helion'), isTrue);
      expect(s2.hasVisited('forum_lokalny'), isTrue);
    });

    test('reset wipes visited (in-memory only)', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      s.markVisited('krs_helion');
      s.reset();
      expect(s.hasVisited('krs_helion'), isFalse);
    });
  });

  group('BrowserState — private mode', () {
    test('private entries are hidden by default', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      expect(s.isPrivateUnlocked, isFalse);
      expect(s.privateEntries, isNotEmpty,
          reason: 'seed must contain at least one private entry');
      expect(s.publicEntries.length + s.privateEntries.length,
          s.entries.length);
      expect(s.visibleEntries, equals(s.publicEntries));
    });

    test('tryUnlockPrivate with correct password unlocks + notifies', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      var hookFired = false;
      s.onPrivateUnlocked = () => hookFired = true;

      expect(s.tryUnlockPrivate('mruczek2019'), isTrue);
      expect(s.isPrivateUnlocked, isTrue);
      expect(s.visibleEntries.length, s.entries.length);
      expect(notifications, 1);
      expect(hookFired, isTrue);
    });

    test('tryUnlockPrivate is case-insensitive and trims whitespace', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      expect(s.tryUnlockPrivate('  Mruczek2019 '), isTrue);
    });

    test('tryUnlockPrivate with wrong password fails', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      var hookFired = false;
      s.onPrivateUnlocked = () => hookFired = true;

      expect(s.tryUnlockPrivate('wrong'), isFalse);
      expect(s.isPrivateUnlocked, isFalse);
      expect(hookFired, isFalse);
    });

    test('cold-load preserves private unlock', () {
      final s1 = BrowserState(persistence: PersistenceService.instance);
      s1.tryUnlockPrivate('mruczek2019');

      final s2 = BrowserState(persistence: PersistenceService.instance);
      expect(s2.isPrivateUnlocked, isTrue);
    });

    test('reset locks private mode again', () {
      final s = BrowserState(persistence: PersistenceService.instance);
      s.tryUnlockPrivate('mruczek2019');
      s.reset();
      expect(s.isPrivateUnlocked, isFalse);
    });
  });
}
