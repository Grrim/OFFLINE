import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaginiona/state/notifications_state.dart';

AppNotification _make(String id) => AppNotification(
      id: id,
      appName: 'Test',
      title: 'T',
      body: 'B',
      icon: Icons.notifications,
      iconBg: const Color(0xFF000000),
    );

void main() {
  group('NotificationsState', () {
    test('starts empty', () {
      final s = NotificationsState();
      expect(s.current, isNull);
    });

    test('push sets current and notifies', () {
      final s = NotificationsState();
      var notifications = 0;
      s.addListener(() => notifications++);

      s.push(_make('a'));
      expect(s.current?.id, 'a');
      expect(notifications, 1);
    });

    test('push appends notification to queue', () {
      final s = NotificationsState();
      s.push(_make('a'));
      s.push(_make('b'));
      expect(s.current?.id, 'a');
      expect(s.all.length, 2);
    });

    test('dismiss clears current', () {
      final s = NotificationsState();
      s.push(_make('a'));
      s.dismiss();
      expect(s.current, isNull);
    });

    test('dismiss is idempotent on empty state', () {
      final s = NotificationsState();
      var notifications = 0;
      s.addListener(() => notifications++);
      s.dismiss();
      expect(notifications, 0);
    });

    test('auto-dismiss after timeout cycles through queue', () {
      fakeAsync((async) {
        final s = NotificationsState();
        s.push(_make('a'));
        s.push(_make('b'));
        expect(s.current?.id, 'a');

        async.elapse(const Duration(seconds: 6));
        expect(s.current?.id, 'b');

        async.elapse(const Duration(seconds: 6));
        expect(s.current, isNull);
      });
    });

    test('reset clears current and timer', () {
      fakeAsync((async) {
        final s = NotificationsState();
        s.push(_make('a'));
        s.reset();
        expect(s.current, isNull);

        // Advancing time after reset should not change anything.
        async.elapse(const Duration(seconds: 10));
        expect(s.current, isNull);
      });
    });
  });
}
