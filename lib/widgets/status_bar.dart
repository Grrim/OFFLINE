import 'dart:async';
import 'package:flutter/material.dart';

/// A thin status bar showing a live clock, signal, wifi and battery icons.
/// Mimics the top bar of a real phone.
class StatusBar extends StatefulWidget {
  const StatusBar({super.key, this.foregroundColor = Colors.white});

  final Color foregroundColor;

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _ticker;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
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
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 16, color: fg),
                const SizedBox(width: 6),
                Icon(Icons.wifi, size: 16, color: fg),
                const SizedBox(width: 6),
                Icon(Icons.battery_full, size: 18, color: fg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
