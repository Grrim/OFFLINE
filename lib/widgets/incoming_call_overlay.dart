import 'dart:async';
import 'package:flutter/material.dart';

import '../services/audio_service.dart';

/// Full-screen overlay for an incoming call.
/// 
/// Reuses the vibe of a real phone call UI (dark background, round buttons, 
/// contact name/location). After 15 seconds of ringing, it auto-fails with 
/// "Brak zasięgu" — matching the game's narrative about signal jamming.
class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({
    super.key,
    required this.callerName,
    this.callerLocation = 'Nieznana lokalizacja',
    required this.onDismiss,
  });

  final String callerName;
  final String callerLocation;
  final VoidCallback onDismiss;

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> {
  Timer? _ringTimeout;
  bool _isRinging = true;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _startRinging();
    // Auto-timeout after 15 seconds.
    _ringTimeout = Timer(const Duration(seconds: 15), _failCall);
  }

  void _startRinging() {
    AudioService.instance.playSfx(GameSfx.callRingtone);
    // Mimic the periodic vibration from _PhoneShell.
    _ringAudioTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _isRinging) {
        AudioService.instance.playSfx(GameSfx.vibrationTable);
      }
    });
  }
  
  Timer? _ringAudioTimer;

  @override
  void dispose() {
    _ringTimeout?.cancel();
    _ringAudioTimer?.cancel();
    super.dispose();
  }

  void _failCall() {
    if (!mounted || _dialogShowing) return;
    
    // Stop ringing immediately
    _ringTimeout?.cancel();
    _ringAudioTimer?.cancel();
    
    setState(() {
      _isRinging = false;
      _dialogShowing = true;
    });

    // Show the "No Signal" error before closing.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Row(
          children: [
            Icon(Icons.signal_cellular_off, color: Colors.white70, size: 22),
            SizedBox(width: 10),
            Text('Połączenie nieudane', style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Brak zasięgu sieci komórkowej. Połączenie zostało przerwane.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDismiss();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF0A84FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.callerLocation,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
              ),
            ),
            const Spacer(),
            // Call control buttons.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CallAction(
                    icon: Icons.call_end,
                    color: const Color(0xFFFF453A),
                    label: 'Odrzuć',
                    onTap: widget.onDismiss,
                  ),
                  _CallAction(
                    icon: Icons.call,
                    color: const Color(0xFF34C759),
                    label: 'Odbierz',
                    onTap: _failCall, // Accepting also fails due to signal narrative.
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  const _CallAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
