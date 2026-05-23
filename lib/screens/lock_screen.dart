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

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  Timer? _clockTicker;
  late DateTime _now;

  // Subtle breathing animation on the dark overlay — makes the lock
  // screen feel alive even without real wallpaper assets.
  late final AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTicker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _breatheCtrl.dispose();
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
          // Same wallpaper as home screen — like a real phone.
          Image.asset(
            'assets/images/home_wallpaper.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0A12), Color(0xFF000000)],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _breatheCtrl,
            builder: (_, __) => Container(
              color: Colors.black.withValues(
                alpha: 0.30 + 0.08 * _breatheCtrl.value,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Scale keypad to fit — on small screens reduce key size.
                final availableHeight = constraints.maxHeight;
                // Reserve space for status bar + clock + date.
                const headerHeight = 120.0;
                final keypadMaxHeight = availableHeight - headerHeight;
                // Standard keypad needs ~420px. Scale down if needed.
                final scale = (keypadMaxHeight / 420).clamp(0.65, 1.0);

                return Column(
                  children: [
                    const StatusBar(),
                    SizedBox(height: 8 * scale),
                    Text(
                      _formatBigTime(_now),
                      style: TextStyle(
                        fontSize: 72 * scale,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatLongDate(_now),
                      style: TextStyle(
                        fontSize: 15 * scale,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: NumericKeypad(
                        title: 'Wprowadź kod',
                        onSubmit: (pin) async {
                          return context.read<PhoneState>().tryUnlock(pin);
                        },
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    // Show hint only after 3 failed attempts.
                    if (context.select<PhoneState, int>(
                            (s) => s.failedAttempts) >=
                        3)
                      Text(
                        'Podpowiedź: Orwell',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11 * scale,
                        ),
                      ),
                    SizedBox(height: 8 * scale),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
