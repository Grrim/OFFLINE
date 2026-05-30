import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/achievements_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('AchievementsState', () {
    test('catalog has at least 14 entries with non-empty fields', () {
      expect(AchievementsState.catalog.length, greaterThanOrEqualTo(14));
      for (final a in AchievementsState.catalog.values) {
        expect(a.id, isNotEmpty);
        expect(a.title, isNotEmpty);
        expect(a.description, isNotEmpty);
      }
    });

    test('starts empty', () {
      final s = AchievementsState(persistence: PersistenceService.instance);
      expect(s.unlockedCount, 0);
      expect(s.totalCount, AchievementsState.catalog.length);
    });

    test('unlock fires callback on first unlock only', () {
      final s = AchievementsState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onAchievementUnlocked = (_) => fireCount++;

      expect(s.unlock('first_unlock'), isTrue);
      expect(s.isUnlocked('first_unlock'), isTrue);
      expect(fireCount, 1);

      // Second time — no fire.
      expect(s.unlock('first_unlock'), isFalse);
      expect(fireCount, 1);
    });

    test('cold-load restores unlocks', () {
      final s1 = AchievementsState(persistence: PersistenceService.instance);
      s1.unlock('first_unlock');
      s1.unlock('detective');

      final s2 = AchievementsState(persistence: PersistenceService.instance);
      expect(s2.isUnlocked('first_unlock'), isTrue);
      expect(s2.isUnlocked('detective'), isTrue);
      expect(s2.unlockedCount, 2);
    });

    test('reset wipes', () {
      final s = AchievementsState(persistence: PersistenceService.instance);
      s.unlock('curious');
      s.reset();
      expect(s.unlockedCount, 0);
    });
  });
}
