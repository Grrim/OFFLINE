import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/evidence_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('EvidenceState — basic', () {
    test('starts empty, score 0', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      expect(s.collected, isEmpty);
      expect(s.score, 0);
      expect(s.count, 0);
    });

    test('collect adds and returns true on first call', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      expect(s.collect('photo_forest_night'), isTrue);
      expect(s.has('photo_forest_night'), isTrue);
      expect(s.score, 20);
      expect(notifications, 1);
    });

    test('collect on existing id returns false and does not notify', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      s.collect('photo_forest_night');
      var notifications = 0;
      s.addListener(() => notifications++);

      expect(s.collect('photo_forest_night'), isFalse);
      expect(notifications, 0);
    });

    test('collectAll returns only newly added ids', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      s.collect('photo_forest_night');

      final added = s.collectAll([
        'photo_forest_night', // already present
        'file_invoice_05',
        'recording_001',
      ]);
      expect(added, {'file_invoice_05', 'recording_001'});
    });

    test('score sums weights of collected items', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      s.collect('photo_forest_night'); // 20
      s.collect('file_transcript'); // 30
      s.collect('recording_003'); // 25
      expect(s.score, 75);
    });

    test('zero-weight items are tracked but do not affect score', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      s.collect('note_secret');
      expect(s.has('note_secret'), isTrue);
      expect(s.score, 0);
      expect(s.count, 1);
    });
  });

  group('EvidenceState — thresholds', () {
    test('canTriggerTruth flips at truthEndingThreshold', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      expect(s.canTriggerTruth, isFalse);
      // 30 + 25 + 15 + 10 = 80
      s.collectAll([
        'file_transcript',
        'recording_003',
        'recording_001',
        'file_invoice_05',
      ]);
      expect(s.score, EvidenceState.truthEndingThreshold);
      expect(s.canTriggerTruth, isTrue);
    });

    test('canTriggerDawn flips at dawnEndingThreshold', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      expect(s.canTriggerDawn, isFalse);
      // pile up evidence
      s.collectAll(EvidenceState.weights.keys);
      expect(s.canTriggerDawn, isTrue);
    });

    test('anitaWouldBelieve flips at anitaSoftBlock', () {
      final s = EvidenceState(persistence: PersistenceService.instance);
      expect(s.anitaWouldBelieve, isFalse);
      s.collectAll(['file_transcript', 'recording_003']); // 30 + 25 = 55
      expect(s.anitaWouldBelieve, isTrue);
    });
  });

  group('EvidenceState — persistence', () {
    test('cold-load preserves collected items', () {
      final s1 = EvidenceState(persistence: PersistenceService.instance);
      s1.collectAll(['photo_forest_night', 'file_invoice_05']);

      final s2 = EvidenceState(persistence: PersistenceService.instance);
      expect(s2.has('photo_forest_night'), isTrue);
      expect(s2.has('file_invoice_05'), isTrue);
      expect(s2.score, 30);
    });

    test('drops unknown ids on cold-load (catalog refactor safety)',
        () async {
      // Simulate a previous save with a now-renamed evidence id.
      SharedPreferences.setMockInitialValues({
        'game.evidence.collected': ['photo_forest_night', 'OLD_RENAMED_ID'],
      });
      await PersistenceService.initForTesting();

      final s = EvidenceState(persistence: PersistenceService.instance);
      expect(s.has('photo_forest_night'), isTrue);
      expect(s.has('OLD_RENAMED_ID'), isFalse);
    });
  });

  test('reset clears all collected', () {
    final s = EvidenceState(persistence: PersistenceService.instance);
    s.collect('photo_forest_night');
    s.reset();
    expect(s.collected, isEmpty);
    expect(s.score, 0);
  });

  test('catalog has positive weights for evidence items (sanity)', () {
    var positiveCount = 0;
    for (final w in EvidenceState.weights.values) {
      if (w > 0) positiveCount++;
    }
    // At least 15 weighted items — keeps the catalog meaningful.
    expect(positiveCount, greaterThanOrEqualTo(15));
  });

  test('thresholds are reachable with the catalog', () {
    final total =
        EvidenceState.weights.values.fold<int>(0, (sum, w) => sum + w);
    expect(total, greaterThanOrEqualTo(EvidenceState.dawnEndingThreshold),
        reason: 'Catalog total must exceed DAWN threshold so the path '
            'is reachable in principle');
  });
}
