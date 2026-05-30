import 'package:flutter/widgets.dart';

/// Lightweight cross-tree dispatcher for shell-level events:
/// - pause / resume gameplay
/// - (future) trigger a content warning, replay-mode tutorial, etc.
///
/// Used by deeply nested widgets (e.g. the home indicator on
/// `HomeScreen`) that need to talk to `_PhoneShellState` without an
/// explicit GlobalKey or tight coupling. The shell wraps the app in
/// [PhoneShellEvents.provider], passing in `onPause`. Children call
/// [PhoneShellEvents.dispatchPause].
class PhoneShellEvents extends InheritedWidget {
  const PhoneShellEvents({
    super.key,
    required this.onPause,
    required super.child,
  });

  final VoidCallback onPause;

  static PhoneShellEvents? _maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PhoneShellEvents>();

  static void dispatchPause(BuildContext context) {
    final inh = _maybeOf(context);
    inh?.onPause();
  }

  @override
  bool updateShouldNotify(PhoneShellEvents old) => onPause != old.onPause;
}
