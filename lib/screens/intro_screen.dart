import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cinematic intro sequence — typewriter text appearing line by line,
/// simulating the player's inner monologue as they find the phone.
/// Each line fades in with a slight delay, creating tension.
/// Tap anywhere to skip (for replays).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  static const _lines = [
    '23:52',
    '',
    'Wracam do domu.',
    'Ciemno. Zimno.',
    '',
    'Coś świeci na chodniku.',
    '',
    'Telefon.',
    'Ekran pęknięty. Jeszcze ciepły.',
    '',
    'Wibruje.',
    '',
    'Ktoś pisze.',
    '',
    '',
    'Podnoszę go.',
  ];

  final List<bool> _visible = [];
  int _currentLine = 0;
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _visible.addAll(List.filled(_lines.length, false));
    _startSequence();
  }

  void _startSequence() {
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_currentLine >= _lines.length) {
        timer.cancel();
        _finish();
        return;
      }

      setState(() {
        _visible[_currentLine] = true;
        _currentLine++;
      });

      // Haptic on certain dramatic lines.
      final line = _currentLine > 0 ? _lines[_currentLine - 1] : '';
      if (line == 'Telefon.' || line == 'Wibruje.' || line == 'Podnoszę go.') {
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _timer?.cancel();

    // Brief pause then transition.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete();
    });
  }

  void _skip() {
    _timer?.cancel();
    setState(() {
      for (var i = 0; i < _visible.length; i++) {
        _visible[i] = true;
      }
    });
    _finish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skip,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                for (var i = 0; i < _lines.length; i++)
                  _buildLine(i),
                const Spacer(flex: 2),
                // Skip hint.
                AnimatedOpacity(
                  opacity: _done ? 0 : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: const Center(
                    child: Text(
                      'dotknij aby pominąć',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLine(int index) {
    final line = _lines[index];

    if (line.isEmpty) {
      return const SizedBox(height: 16);
    }

    final isTime = index == 0;
    final isDramatic = line == 'Telefon.' ||
        line == 'Wibruje.' ||
        line == 'Ktoś pisze.' ||
        line == 'Podnoszę go.';

    return AnimatedOpacity(
      opacity: _visible[index] ? 1.0 : 0.0,
      duration: Duration(milliseconds: isDramatic ? 600 : 400),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          line,
          style: TextStyle(
            color: isDramatic
                ? Colors.white
                : isTime
                    ? Colors.white38
                    : Colors.white70,
            fontSize: isDramatic
                ? 20
                : isTime
                    ? 13
                    : 16,
            fontWeight: isDramatic ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: isTime ? 2 : 0,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
