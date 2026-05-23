import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fullscreen "8 hours later" overlay shown on the chapter 1 → 2
/// transition. Auto-dismisses after ~5 seconds.
///
/// Mounted by the phone shell when [ChapterState.shouldAnimateTransition]
/// is true. The shell clears the flag after [onComplete] fires.
class ChapterTransitionOverlay extends StatefulWidget {
  const ChapterTransitionOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<ChapterTransitionOverlay> createState() =>
      _ChapterTransitionOverlayState();
}

class _ChapterTransitionOverlayState extends State<ChapterTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    // Heavy haptic at the start — feels like a beat drop.
    HapticFeedback.heavyImpact();

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        // Fade in 0-0.2, hold 0.2-0.7, fade out 0.7-1.0.
        double opacity;
        if (t < 0.2) {
          opacity = (t / 0.2);
        } else if (t < 0.7) {
          opacity = 1.0;
        } else {
          opacity = ((1.0 - t) / 0.3).clamp(0.0, 1.0);
        }

        return Material(
          color: Colors.black.withValues(alpha: opacity * 0.98),
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    color: const Color(0xFF5AC8FA).withValues(alpha: 0.85),
                    size: 56,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '8 GODZIN PÓŹNIEJ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Świt nad Warszawą',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
