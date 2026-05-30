import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistenceService schema migration', () {
    test('legacy unprefixed keys are migrated to game.* on first init',
        () async {
      // Simulate a save from before versioning was introduced.
      SharedPreferences.setMockInitialValues({
        'phone.isUnlocked': true,
        'photos.inspected': ['forest_night', 'parking'],
        'notes.unlockedIds': ['secret'],
        'notes.hookFired': true,
        'files.opened': ['faktura_2026_05', 'transkrypcja'],
        'browser.visited': ['krs_helion'],
        'chapter.current': ['two'],
        'ending.activeId': ['truth'],
        'messages.progress.v1': ['{"id":"mama","messages":[]}'],
      });

      final svc = await PersistenceService.initForTesting();

      // Schema version recorded.
      expect(svc.getInt('__schema_version__'),
          PersistenceService.currentSchemaVersion);

      // New keys populated.
      expect(svc.getBool('game.phone.isUnlocked'), isTrue);
      expect(svc.getStringList('game.photos.inspected'),
          ['forest_night', 'parking']);
      expect(svc.getStringList('game.notes.unlockedIds'), ['secret']);
      expect(svc.getBool('game.notes.hookFired'), isTrue);
      expect(svc.getStringList('game.files.opened'),
          ['faktura_2026_05', 'transkrypcja']);
      expect(svc.getStringList('game.browser.visited'), ['krs_helion']);
      expect(svc.getStringList('game.chapter.current'), ['two']);
      expect(svc.getStringList('game.ending.activeId'), ['truth']);
      expect(svc.getStringList('game.messages.progress.v1').length, 1);

      // Legacy keys are removed.
      expect(svc.containsKey('phone.isUnlocked'), isFalse);
      expect(svc.containsKey('photos.inspected'), isFalse);
      expect(svc.containsKey('notes.unlockedIds'), isFalse);
    });

    test('migration is idempotent (re-running does not re-migrate)',
        () async {
      SharedPreferences.setMockInitialValues({
        'phone.isUnlocked': true,
      });
      final svc1 = await PersistenceService.initForTesting();
      expect(svc1.getBool('game.phone.isUnlocked'), isTrue);

      // Now write a fresh value to the new key, then re-init.
      // Without proper version tracking, migration could overwrite it.
      await svc1.setBool('game.phone.isUnlocked', false);
      final svc2 = await PersistenceService.initForTesting();
      expect(svc2.getBool('game.phone.isUnlocked'), isFalse);
    });

    test('migration keeps existing new-style key when both exist',
        () async {
      // Edge case: somehow both old and new key are present.
      // The new key takes precedence and the old is dropped.
      SharedPreferences.setMockInitialValues({
        'phone.isUnlocked': true,
        'game.phone.isUnlocked': false,
      });
      final svc = await PersistenceService.initForTesting();
      expect(svc.getBool('game.phone.isUnlocked'), isFalse);
      expect(svc.containsKey('phone.isUnlocked'), isFalse);
    });

    test('fresh install (no legacy keys) just stamps schema version',
        () async {
      SharedPreferences.setMockInitialValues({});
      final svc = await PersistenceService.initForTesting();
      expect(svc.getInt('__schema_version__'),
          PersistenceService.currentSchemaVersion);
    });
  });

  group('clearGameState', () {
    test('wipes game.* keys but preserves settings.* and schema version',
        () async {
      SharedPreferences.setMockInitialValues({});
      final svc = await PersistenceService.initForTesting();

      await svc.setBool('game.phone.isUnlocked', true);
      await svc.setStringList('game.photos.inspected', ['a', 'b']);
      await svc.setBool('settings.audio.muted', true);
      await svc.setString('settings.locale', 'pl');

      await svc.clearGameState();

      // Game keys gone.
      expect(svc.containsKey('game.phone.isUnlocked'), isFalse);
      expect(svc.containsKey('game.photos.inspected'), isFalse);

      // Settings preserved.
      expect(svc.getBool('settings.audio.muted'), isTrue);
      expect(svc.getString('settings.locale'), 'pl');

      // Schema version preserved.
      expect(svc.getInt('__schema_version__'),
          PersistenceService.currentSchemaVersion);
    });
  });

  group('singleton', () {
    test('throws if accessed before init', () {
      // Reset singleton state — there's no public reset, so we accept
      // that this test runs in isolation. Skipped to avoid test order
      // dependency.
    }, skip: 'no test isolation primitive yet');
  });
}
