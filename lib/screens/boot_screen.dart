import 'package:flutter/material.dart';

/// Simulates a phone boot sequence — brief black screen with a subtle
/// logo fade-in, then auto-transitions to the lock screen.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

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

        // Phase 1 (0-0.3): black screen
        // Phase 2 (0.3-0.7): logo fades in
        // Phase 3 (0.7-1.0): logo fades out, screen stays black
        double logoOpacity;
        if (t < 0.3) {
          logoOpacity = 0;
        } else if (t < 0.7) {
          logoOpacity = ((t - 0.3) / 0.4).clamp(0.0, 1.0);
        } else {
          logoOpacity = ((1.0 - t) / 0.3).clamp(0.0, 1.0);
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Opacity(
              opacity: logoOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimalist "phone" icon as the boot logo.
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.smartphone,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ZAGINIONA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
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
