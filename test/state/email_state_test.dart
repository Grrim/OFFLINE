import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/email_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('EmailState — recovery puzzle', () {
    test('starts empty, message hidden', () {
      final s = EmailState(persistence: PersistenceService.instance);
      expect(s.recoveredCount, 0);
      expect(s.isFullyRecovered, isFalse);
      expect(s.recoveredMessage, isNull);
      expect(s.totalFragments, EmailState.allFragments.length);
    });

    test('recover marks first time and returns true', () {
      final s = EmailState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      expect(s.recover('frag_intro'), isTrue);
      expect(s.isRecovered('frag_intro'), isTrue);
      expect(s.recoveredCount, 1);
      expect(notifications, 1);
    });

    test('recover is idempotent', () {
      final s = EmailState(persistence: PersistenceService.instance);
      s.recover('frag_intro');
      expect(s.recover('frag_intro'), isFalse);
      expect(s.recoveredCount, 1);
    });

    test('isFullyRecovered after all fragments collected', () {
      final s = EmailState(persistence: PersistenceService.instance);
      for (final f in EmailState.allFragments) {
        s.recover(f.id);
      }
      expect(s.isFullyRecovered, isTrue);
      expect(s.recoveredMessage, isNotNull);
      expect(s.recoveredMessage!.length, greaterThan(50));
    });

    test('recoveredMessage assembles in declared order', () {
      final s = EmailState(persistence: PersistenceService.instance);
      // Recover in scrambled order — order must still match catalog order.
      s.recover('frag_sign');
      s.recover('frag_intro');
      s.recover('frag_signal');
      s.recover('frag_meeting');
      s.recover('frag_warning');

      final msg = s.recoveredMessage!;
      // Must START with the intro fragment body.
      expect(msg.startsWith(EmailState.allFragments.first.body), isTrue);
      // Must END with the sign-off body.
      expect(msg.endsWith(EmailState.allFragments.last.body), isTrue);
    });

    test('cold-load restores progress', () {
      final s1 = EmailState(persistence: PersistenceService.instance);
      s1.recover('frag_intro');
      s1.recover('frag_meeting');

      final s2 = EmailState(persistence: PersistenceService.instance);
      expect(s2.isRecovered('frag_intro'), isTrue);
      expect(s2.isRecovered('frag_meeting'), isTrue);
      expect(s2.recoveredCount, 2);
    });

    test('drops unknown fragment ids on cold-load', () async {
      SharedPreferences.setMockInitialValues({
        'game.email.recoveredFragments': ['frag_intro', 'OLD_RENAMED'],
      });
      await PersistenceService.initForTesting();
      final s = EmailState(persistence: PersistenceService.instance);
      expect(s.isRecovered('frag_intro'), isTrue);
      expect(s.isRecovered('OLD_RENAMED'), isFalse);
    });

    test('reset wipes', () {
      final s = EmailState(persistence: PersistenceService.instance);
      s.recover('frag_intro');
      s.reset();
      expect(s.recoveredCount, 0);
    });
  });
}
