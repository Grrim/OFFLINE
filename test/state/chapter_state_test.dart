import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/chapter_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('ChapterState', () {
    test('starts at chapter one with no transition pending', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      expect(s.current, Chapter.one);
      expect(s.isChapter2, isFalse);
      expect(s.isChapter3, isFalse);
      expect(s.shouldAnimateTransition, isFalse);
    });

    test('advanceToChapter2 advances and arms transition', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.advanceToChapter2();
      expect(s.current, Chapter.two);
      expect(s.isChapter2, isTrue);
      expect(s.shouldAnimateTransition, isTrue);
      expect(notifications, 1);
    });

    test('advanceToChapter2 is idempotent', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter2();
      var notifications = 0;
      s.addListener(() => notifications++);

      s.advanceToChapter2();
      s.advanceToChapter2();
      expect(notifications, 0);
      expect(s.current, Chapter.two);
    });

    test('advanceToChapter2(fromColdLoad: true) skips transition flag', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter2(fromColdLoad: true);
      expect(s.current, Chapter.two);
      expect(s.shouldAnimateTransition, isFalse);
    });

    test('advanceToChapter3 only works from chapter 2', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter3();
      expect(s.current, Chapter.one,
          reason: 'cannot skip ch1 → ch3 directly');

      s.advanceToChapter2();
      s.advanceToChapter3();
      expect(s.current, Chapter.three);
      expect(s.isChapter3, isTrue);
      expect(s.isChapter2, isFalse, reason: 'isChapter2 only matches ch2');
      expect(s.shouldAnimateTransition, isTrue);
    });

    test('advanceToChapter3 idempotent', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter2();
      s.advanceToChapter3();
      var notifications = 0;
      s.addListener(() => notifications++);

      s.advanceToChapter3();
      s.advanceToChapter3();
      expect(notifications, 0);
    });

    test('clearTransitionFlag clears the flag and notifies', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter2();
      expect(s.shouldAnimateTransition, isTrue);

      var notifications = 0;
      s.addListener(() => notifications++);
      s.clearTransitionFlag();
      expect(s.shouldAnimateTransition, isFalse);
      expect(notifications, 1);

      // Idempotent — no second notify.
      s.clearTransitionFlag();
      expect(notifications, 1);
    });

    test('cold-load restores chapter 2 (without animation flag)', () {
      final s1 = ChapterState(persistence: PersistenceService.instance);
      s1.advanceToChapter2();
      expect(s1.current, Chapter.two);

      final s2 = ChapterState(persistence: PersistenceService.instance);
      expect(s2.current, Chapter.two);
      expect(s2.shouldAnimateTransition, isFalse);
    });

    test('cold-load restores chapter 3', () {
      final s1 = ChapterState(persistence: PersistenceService.instance);
      s1.advanceToChapter2();
      s1.advanceToChapter3();

      final s2 = ChapterState(persistence: PersistenceService.instance);
      expect(s2.current, Chapter.three);
      expect(s2.shouldAnimateTransition, isFalse);
    });

    test('reset returns to chapter one', () {
      final s = ChapterState(persistence: PersistenceService.instance);
      s.advanceToChapter2();
      s.advanceToChapter3();
      s.reset();
      expect(s.current, Chapter.one);
      expect(s.shouldAnimateTransition, isFalse);
    });
  });
}
