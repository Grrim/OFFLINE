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
  AppNotification? _current;
  Timer? _autoDismiss;

  AppNotification? get current => _current;

  /// Default visible time. Long enough to read the body comfortably.
  static const Duration _visibleFor = Duration(seconds: 5);

  void push(AppNotification n) {
    _autoDismiss?.cancel();
    _current = n;
    notifyListeners();
    _autoDismiss = Timer(_visibleFor, dismiss);
  }

  void dismiss() {
    _autoDismiss?.cancel();
    _autoDismiss = null;
    if (_current != null) {
      _current = null;
      notifyListeners();
    }
  }

  void reset() {
    _autoDismiss?.cancel();
    _autoDismiss = null;
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    super.dispose();
  }
}
