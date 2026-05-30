import 'dart:async';
import 'package:flutter/material.dart';

/// One push-style notification banner.
class AppNotification {
  AppNotification({
    required this.id,
    required this.appName,
    required this.title,
    required this.body,
    required this.icon,
    required this.iconBg,
    this.onTap,
  });

  final String id;
  final String appName;
  final String title;
  final String body;
  final IconData icon;
  final Color iconBg;

  /// Called when the user taps the banner. The banner self-dismisses first.
  final VoidCallback? onTap;
}

/// OS-level notification queue. A widget mounted near the root listens to
/// [current] and renders the actual banner.
///
/// Kept tiny on purpose: one slot at a time, auto-dismiss timer, manual
/// dismiss method. If multiple fire close together they replace each other,
/// which matches the "system push" feel we want.
class NotificationsState extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  Timer? _autoDismiss;

  AppNotification? get current => _notifications.isEmpty ? null : _notifications.first;
  List<AppNotification> get all => List.unmodifiable(_notifications);

  /// Default visible time. Long enough to read the body comfortably.
  static const Duration _visibleFor = Duration(seconds: 5);

  void push(AppNotification n) {
    _notifications.add(n);
    notifyListeners();
    // Only set auto-dismiss for the first notification in the queue
    if (_notifications.length == 1) {
      _startDismissTimer();
    }
  }

  void dismiss() {
    if (_notifications.isNotEmpty) {
      _notifications.removeAt(0);
      _autoDismiss?.cancel();
      _autoDismiss = null;
      notifyListeners();
      if (_notifications.isNotEmpty) {
        _startDismissTimer();
      }
    }
  }

  void _startDismissTimer() {
    _autoDismiss?.cancel();
    _autoDismiss = Timer(_visibleFor, dismiss);
  }

  void reset() {
    _autoDismiss?.cancel();
    _autoDismiss = null;
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }
}
