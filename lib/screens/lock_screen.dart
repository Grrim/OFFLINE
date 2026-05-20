import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/phone_state.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/status_bar.dart';

/// Realistic lock screen: wallpaper, big clock, big date, and the shared
/// [NumericKeypad] for the PIN ("1984"). On success we flip
/// [PhoneState.isUnlocked] which causes the phone shell to swap to the
/// home screen with a cross-fade.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  Timer? _clockTicker;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTicker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    super.dispose();
  }

  String _formatBigTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatLongDate(DateTime t) {
    const days = [
      'poniedziałek', 'wtorek', 'środa', 'czwartek', 'piątek',
      'sobota', 'niedziela',
    ];
    const months = [
      'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
      'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia',
    ];
    final day = days[(t.weekday - 1).clamp(0, 6)];
    final month = months[(t.month - 1).clamp(0, 11)];
    final capitalised = day[0].toUpperCase() + day.substring(1);
    return '$capitalised, ${t.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Wallpaper ----
          // Place your wallpaper at: assets/images/lockscreen_wallpaper.jpg
          Image.asset(
            'assets/images/lockscreen_wallpaper.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF101015), Color(0xFF000000)],
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.35)),

          SafeArea(
            child: Column(
              children: [
                const StatusBar(),
                const SizedBox(height: 24),
                Text(
                  _formatBigTime(_now),
                  style: const TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatLongDate(_now),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                NumericKeypad(
                  title: 'Wprowadź kod',
                  onSubmit: (pin) async {
                    return context.read<PhoneState>().tryUnlock(pin);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
