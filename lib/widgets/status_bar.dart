import 'dart:async';
import 'package:flutter/material.dart';

/// A thin status bar showing a live clock, signal, wifi and battery icons.
/// Mimics the top bar of a real phone. Battery drains slowly during gameplay.
class StatusBar extends StatefulWidget {
  const StatusBar({super.key, this.foregroundColor = Colors.white});

  final Color foregroundColor;

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _ticker;
  late DateTime _now;

  /// Simulated battery — starts at 37%, drops 1% per minute.
  static DateTime? _sessionStart;
  static const int _startBattery = 37;

  int get _battery {
    final start = _sessionStart ??= DateTime.now();
    final elapsed = DateTime.now().difference(start).inMinutes;
    return (_startBattery - elapsed).clamp(5, 100);
  }

  @override
  void initState() {
    super.initState();
    _sessionStart ??= DateTime.now();
    _now = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.foregroundColor;
    final bat = _battery;
    final batColor = bat <= 15
        ? const Color(0xFFFF453A)
        : bat <= 25
            ? const Color(0xFFFF9500)
            : fg;
    final batIcon = bat <= 15
        ? Icons.battery_1_bar
        : bat <= 25
            ? Icons.battery_2_bar
            : bat <= 50
                ? Icons.battery_3_bar
                : Icons.battery_5_bar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: DefaultTextStyle(
        style: TextStyle(
          color: fg,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTime(_now)),
            Text(
              'HB_Guest',
              style: TextStyle(
                color: fg.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_off, size: 16, color: fg.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Icon(Icons.wifi, size: 16, color: fg),
                const SizedBox(width: 6),
                Icon(batIcon, size: 18, color: batColor),
                const SizedBox(width: 2),
                Text(
                  '$bat%',
                  style: TextStyle(color: batColor, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
