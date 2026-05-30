import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_extensions.dart';
import '../state/phone_state.dart';
import '../state/notifications_state.dart';
import '../services/l10n_service.dart';
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
    final locale = L10nService.instance.locale.toString();
    // Using intl DateFormat for automatic localization
    final dayName = DateFormat('EEEE', locale).format(t);
    final day = t.day;
    final monthName = DateFormat('MMMM', locale).format(t);
    
    // Capitalize first letter of day name
    final capitalizedDay = dayName[0].toUpperCase() + dayName.substring(1);
    
    if (locale == 'pl') {
      return '$capitalizedDay, $day $monthName';
    } else {
      return '$capitalizedDay, $monthName $day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Same wallpaper as home screen — like a real phone.
          Image.asset(
            'assets/images/lockscreen_wallpaper.jpg',
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: Consumer<NotificationsState>(
                        builder: (context, state, _) {
                          final list = state.all;
                          if (list.isEmpty) return const SizedBox.shrink();
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final n = list[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: n.iconBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(n.icon, color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            n.body,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: NumericKeypad(
                        title: context.l10n.lockEnterPin,
                        errorMessage: context.l10n.lockWrongPin,
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
                        context.l10n.lockHintOrwell,
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
