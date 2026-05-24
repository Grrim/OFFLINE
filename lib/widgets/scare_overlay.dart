import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/audio_service.dart';

/// Manages random scare events — blackouts and fake crashes.
/// Mount as Positioned.fill in the phone shell Stack.
class ScareOverlay extends StatefulWidget {
  const ScareOverlay({super.key, required this.active});

  /// Only trigger scares when the phone is unlocked and no ending is active.
  final bool active;

  @override
  State<ScareOverlay> createState() => _ScareOverlayState();
}

class _ScareOverlayState extends State<ScareOverlay> {
  final _rng = Random();
  Timer? _scheduleTimer;
  _ScareType? _currentScare;

  @override
  void initState() {
    super.initState();
    if (widget.active) _scheduleNext();
  }

  @override
  void didUpdateWidget(covariant ScareOverlay old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _scheduleNext();
    } else if (!widget.active && old.active) {
      _scheduleTimer?.cancel();
      setState(() => _currentScare = null);
    }
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _scheduleNext() {
    if (!widget.active) return;
    // Random interval between 90s and 180s.
    final delay = Duration(seconds: 90 + _rng.nextInt(90));
    _scheduleTimer = Timer(delay, _triggerScare);
  }

  void _triggerScare() {
    if (!mounted || !widget.active) return;

    // Alternate between blackout and fake crash.
    final type = _rng.nextBool() ? _ScareType.blackout : _ScareType.fakeCrash;
    setState(() => _currentScare = type);

    HapticFeedback.heavyImpact();
    AudioService.instance.playSfx(GameSfx.glitchBurst);

    // Auto-dismiss after duration.
    final duration = type == _ScareType.blackout
        ? const Duration(seconds: 2)
        : const Duration(seconds: 4);

    Future.delayed(duration, () {
      if (!mounted) return;
      setState(() => _currentScare = null);
      _scheduleNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScare == null) return const SizedBox.shrink();

    return switch (_currentScare!) {
      _ScareType.blackout => const _BlackoutWidget(),
      _ScareType.fakeCrash => _FakeCrashWidget(
          onDismiss: () => setState(() => _currentScare = null),
        ),
    };
  }
}

enum _ScareType { blackout, fakeCrash }

/// Full black screen for 2 seconds — simulates phone dying.
class _BlackoutWidget extends StatelessWidget {
  const _BlackoutWidget();

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }
}

/// Fake "App not responding" dialog — looks like Android system dialog.
class _FakeCrashWidget extends StatelessWidget {
  const _FakeCrashWidget({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFFF453A), size: 36),
              const SizedBox(height: 12),
              const Text(
                'Aplikacja nie odpowiada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Czy chcesz zamknąć aplikację?',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // "Czekaj" does nothing visible — dialog auto-dismisses.
                        HapticFeedback.lightImpact();
                      },
                      child: const Text('Czekaj',
                          style: TextStyle(color: Color(0xFF0A84FF))),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // "Zamknij" also does nothing — creepy.
                        HapticFeedback.heavyImpact();
                      },
                      child: const Text('Zamknij',
                          style: TextStyle(color: Color(0xFFFF453A))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
