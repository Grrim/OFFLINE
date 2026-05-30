import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/recorder_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('RecorderState — basic', () {
    test('seeded with 4 recordings, none listened', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      expect(s.recordings.length, 4);
      expect(s.unreadCount, 4);
      for (final r in s.recordings) {
        expect(s.hasListened(r.id), isFalse);
      }
    });

    test('markListened decreases unreadCount + fires hook once', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      var fireCount = 0;
      String? lastId;
      s.onFirstListened = (id) {
        fireCount++;
        lastId = id;
      };

      expect(s.markListened('rec_001'), isTrue);
      expect(s.unreadCount, 3);
      expect(lastId, 'rec_001');

      // Re-listen — no new fire.
      expect(s.markListened('rec_001'), isFalse);
      expect(fireCount, 1);
    });

    test('cold-load preserves listened ids', () {
      final s1 = RecorderState(persistence: PersistenceService.instance);
      s1.markListened('rec_001');
      s1.markListened('rec_002');

      final s2 = RecorderState(persistence: PersistenceService.instance);
      expect(s2.hasListened('rec_001'), isTrue);
      expect(s2.hasListened('rec_002'), isTrue);
      expect(s2.unreadCount, 2);
    });
  });

  group('RecorderState — voice match puzzle', () {
    test('starts unmatched', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      expect(s.isFullyMatched, isFalse);
      expect(s.hasCorrectMatches, isFalse);
      expect(s.correctCount, 0);
    });

    test('partial assignments do not solve', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      s.assignVoice('rec_001', 'anita_z'); // correct
      s.assignVoice('rec_002', 'tomasz_b'); // wrong
      expect(s.isFullyMatched, isFalse);
      expect(s.hasCorrectMatches, isFalse);
      expect(s.correctCount, 1);
    });

    test('all-correct fires onVoicePuzzleSolved exactly once', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onVoicePuzzleSolved = () => fireCount++;

      s.assignVoice('rec_001', 'anita_z');
      s.assignVoice('rec_002', 'komendant_k');
      s.assignVoice('rec_003', 'tomasz_b');
      expect(s.hasCorrectMatches, isTrue);
      expect(fireCount, 1);

      // Re-assigning a correct one to itself does not re-fire.
      s.assignVoice('rec_001', 'anita_z');
      expect(fireCount, 1);
    });

    test('changing one to wrong then back fires only once across runs',
        () {
      final s = RecorderState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onVoicePuzzleSolved = () => fireCount++;

      s.assignVoice('rec_001', 'anita_z');
      s.assignVoice('rec_002', 'komendant_k');
      s.assignVoice('rec_003', 'tomasz_b');
      expect(fireCount, 1);

      s.assignVoice('rec_002', 'tata'); // break it
      expect(s.hasCorrectMatches, isFalse);
      s.assignVoice('rec_002', 'komendant_k'); // restore
      expect(s.hasCorrectMatches, isTrue);
      expect(fireCount, 1, reason: 'Already fired once this run');
    });

    test('clearAssignment removes pick', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      s.assignVoice('rec_001', 'anita_z');
      expect(s.assignmentFor('rec_001'), 'anita_z');
      s.clearAssignment('rec_001');
      expect(s.assignmentFor('rec_001'), isNull);
    });

    test('cold-load restores assignments', () {
      final s1 = RecorderState(persistence: PersistenceService.instance);
      s1.assignVoice('rec_001', 'anita_z');
      s1.assignVoice('rec_002', 'komendant_k');

      final s2 = RecorderState(persistence: PersistenceService.instance);
      expect(s2.assignmentFor('rec_001'), 'anita_z');
      expect(s2.assignmentFor('rec_002'), 'komendant_k');
    });

    test('reset wipes assignments + listened', () {
      final s = RecorderState(persistence: PersistenceService.instance);
      s.markListened('rec_001');
      s.assignVoice('rec_001', 'anita_z');

      s.reset();
      expect(s.unreadCount, s.recordings.length);
      expect(s.assignmentFor('rec_001'), isNull);
    });
  });
}
