import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../services/audio_service.dart';

/// A subtle screen-glitch overlay that simulates digital interference.
/// Activated when the Sheriff is "watching" — creates unease without
/// blocking interaction.
///
/// Mount it in a Stack above the main content. When [active] is true it
/// periodically flashes thin horizontal colour-shifted bars and a brief
/// opacity flicker, then goes dormant for a random interval.
class GlitchOverlay extends StatefulWidget {
  const GlitchOverlay({super.key, required this.active});

  final bool active;

  @override
  State<GlitchOverlay> createState() => _GlitchOverlayState();
}

class _GlitchOverlayState extends State<GlitchOverlay> {
  final _rng = Random();
  Timer? _burstTimer;
  bool _glitching = false;
  double _opacity = 0;
  List<_GlitchBar> _bars = [];

  @override
  void initState() {
    super.initState();
    if (widget.active) _scheduleBurst();
  }

  @override
  void didUpdateWidget(covariant GlitchOverlay old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _scheduleBurst();
    } else if (!widget.active && old.active) {
      _burstTimer?.cancel();
      _burstTimer = null;
      setState(() {
        _glitching = false;
        _opacity = 0;
      });
    }
  }

  @override
  void dispose() {
    _burstTimer?.cancel();
    super.dispose();
  }

  void _scheduleBurst() {
    if (!widget.active) return;
    final delay = Duration(milliseconds: 2000 + _rng.nextInt(4000));
    _burstTimer = Timer(delay, _doBurst);
  }

  Future<void> _doBurst() async {
    if (!mounted || !widget.active) return;

    // Play glitch sound on some bursts (not every one — would be annoying).
    if (_rng.nextDouble() < 0.4) {
      AudioService.instance.playSfx(GameSfx.glitchBurst);
    }

    // Generate random glitch bars.
    setState(() {
      _glitching = true;
      _opacity = 0.12 + _rng.nextDouble() * 0.15;
      _bars = List.generate(2 + _rng.nextInt(3), (_) => _GlitchBar.random(_rng));
    });

    // Hold the glitch for a brief moment.
    await Future.delayed(Duration(milliseconds: 60 + _rng.nextInt(100)));
    if (!mounted) return;

    setState(() {
      _glitching = false;
      _opacity = 0;
      _bars = [];
    });

    // Sometimes do a quick double-glitch.
    if (_rng.nextDouble() < 0.35) {
      await Future.delayed(Duration(milliseconds: 80 + _rng.nextInt(120)));
      if (!mounted || !widget.active) return;
      setState(() {
        _glitching = true;
        _opacity = 0.08 + _rng.nextDouble() * 0.10;
        _bars = List.generate(1 + _rng.nextInt(2), (_) => _GlitchBar.random(_rng));
      });
      await Future.delayed(Duration(milliseconds: 40 + _rng.nextInt(60)));
      if (!mounted) return;
      setState(() {
        _glitching = false;
        _opacity = 0;
        _bars = [];
      });
    }

    _scheduleBurst();
  }

  @override
  Widget build(BuildContext context) {
    if (!_glitching) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: [
          // Full-screen red/cyan tint flash.
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFF0000).withValues(alpha: _opacity * 0.5),
            ),
          ),
          // Horizontal scan-line bars.
          for (final bar in _bars)
            Positioned(
              top: bar.topFraction * MediaQuery.of(context).size.height,
              left: bar.offsetX,
              right: -bar.offsetX,
              height: bar.height,
              child: Container(
                color: bar.color.withValues(alpha: _opacity),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlitchBar {
  _GlitchBar({
    required this.topFraction,
    required this.height,
    required this.offsetX,
    required this.color,
  });

  final double topFraction;
  final double height;
  final double offsetX;
  final Color color;

  factory _GlitchBar.random(Random rng) {
    final colors = [
      const Color(0xFFFF0040),
      const Color(0xFF00FFFF),
      const Color(0xFFFF00FF),
      Colors.white,
    ];
    return _GlitchBar(
      topFraction: rng.nextDouble(),
      height: 1.0 + rng.nextDouble() * 4,
      offsetX: (rng.nextDouble() - 0.5) * 12,
      color: colors[rng.nextInt(colors.length)],
    );
  }
}
