import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/files_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('FilesState', () {
    test('seeded with at least 5 documents, all unread initially', () {
      final s = FilesState(persistence: PersistenceService.instance);
      expect(s.files.length, greaterThanOrEqualTo(5));
      expect(s.openedCount, 0);
      expect(s.unreadCount, s.files.length);
      for (final f in s.files) {
        expect(s.hasOpened(f.id), isFalse);
      }
    });

    test('markOpened decreases unreadCount and increases openedCount', () {
      final s = FilesState(persistence: PersistenceService.instance);
      final firstId = s.files.first.id;
      s.markOpened(firstId);
      expect(s.hasOpened(firstId), isTrue);
      expect(s.openedCount, 1);
      expect(s.unreadCount, s.files.length - 1);
    });

    test('markOpened is idempotent', () {
      final s = FilesState(persistence: PersistenceService.instance);
      final id = s.files.first.id;
      s.markOpened(id);
      s.markOpened(id);
      s.markOpened(id);
      expect(s.openedCount, 1);
    });

    test('onFirstFileOpened fires exactly once on first open', () {
      final s = FilesState(persistence: PersistenceService.instance);
      var firstFireCount = 0;
      s.onFirstFileOpened = () => firstFireCount++;

      s.markOpened(s.files[0].id);
      s.markOpened(s.files[1].id);
      s.markOpened(s.files[2].id);
      expect(firstFireCount, 1);
    });

    test('onChapter2Threshold fires once when threshold is crossed', () {
      final s = FilesState(persistence: PersistenceService.instance);
      var thresholdFireCount = 0;
      s.onChapter2Threshold = () => thresholdFireCount++;

      // Open just below the threshold — no fire.
      for (var i = 0; i < FilesState.chapter2OpenThreshold - 1; i++) {
        s.markOpened(s.files[i].id);
      }
      expect(thresholdFireCount, 0);

      // Cross the threshold — fires once.
      s.markOpened(s.files[FilesState.chapter2OpenThreshold - 1].id);
      expect(thresholdFireCount, 1);

      // Further opens — does not re-fire.
      if (s.files.length > FilesState.chapter2OpenThreshold) {
        s.markOpened(s.files[FilesState.chapter2OpenThreshold].id);
        expect(thresholdFireCount, 1);
      }
    });

    test('cold-load preserves opened files', () {
      final s1 = FilesState(persistence: PersistenceService.instance);
      s1.markOpened(s1.files[0].id);
      s1.markOpened(s1.files[1].id);

      final s2 = FilesState(persistence: PersistenceService.instance);
      expect(s2.hasOpened(s1.files[0].id), isTrue);
      expect(s2.hasOpened(s1.files[1].id), isTrue);
      expect(s2.openedCount, 2);
    });

    test('reset wipes opened and re-arms triggers', () {
      final s = FilesState(persistence: PersistenceService.instance);
      var firstFireCount = 0;
      s.onFirstFileOpened = () => firstFireCount++;

      s.markOpened(s.files.first.id);
      expect(firstFireCount, 1);

      s.reset();
      expect(s.openedCount, 0);

      // After reset, the trigger should be re-armed.
      s.markOpened(s.files.first.id);
      expect(firstFireCount, 2);
    });
  });
}
