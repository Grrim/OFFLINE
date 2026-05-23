import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/status_bar.dart';

/// Phone app — call log showing missed calls. Tapping any entry
/// triggers a "Brak zasięgu" error, reinforcing the isolation.
class PhoneView extends StatelessWidget {
  const PhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF34C759), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Ostatnie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Nieodebrane',
                    style: TextStyle(
                      color: Color(0xFFFF453A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CallEntry(
                    name: 'Mama',
                    count: 7,
                    time: 'Wczoraj, 22:14',
                    isMissed: true,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Mama',
                    count: 3,
                    time: 'Wczoraj, 18:30',
                    isMissed: true,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Nieznany numer',
                    count: 1,
                    time: 'Wczoraj, 23:48',
                    isMissed: true,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Anita Z. (Gazeta)',
                    count: 2,
                    time: 'Piątek, 15:22',
                    isMissed: true,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Praca',
                    count: 1,
                    time: 'Piątek, 09:15',
                    isMissed: true,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Mama',
                    count: 1,
                    time: 'Czwartek, 20:00',
                    isMissed: false,
                    onTap: () => _showNoSignal(context),
                  ),
                  _CallEntry(
                    name: 'Cafe Relaks',
                    count: 1,
                    time: 'Środa, 11:30',
                    isMissed: false,
                    onTap: () => _showNoSignal(context),
                  ),
                  const SizedBox(height: 24),
                  // Voicemail section.
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'POCZTA GŁOSOWA',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const _VoicemailEntry(
                    name: 'Mama',
                    time: 'Wczoraj, 22:16',
                    duration: '0:47',
                    transcript:
                        'Kochanie... [płacz] ...nie wiem co się dzieje, '
                        'dzwonię i dzwonię, nie odbierasz... Tata mówi '
                        'żebym się nie martwiła ale ja wiem że coś jest '
                        'nie tak... Zadzwoń do mnie jak tylko to usłyszysz, '
                        'błagam... Kocham cię.',
                  ),
                  const _VoicemailEntry(
                    name: 'Nieznany numer',
                    time: 'Wczoraj, 23:49',
                    duration: '0:12',
                    transcript:
                        '[cisza, 4 sekundy] ...wiem gdzie mieszkasz. '
                        '[rozłączenie]',
                    isThreat: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoSignal(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Row(
          children: [
            Icon(Icons.signal_cellular_off, color: Colors.white70, size: 22),
            SizedBox(width: 10),
            Text('Połączenie nieudane',
                style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Brak zasięgu sieci komórkowej. Nie można nawiązać połączenia.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF0A84FF))),
          ),
        ],
      ),
    );
  }
}

class _CallEntry extends StatelessWidget {
  const _CallEntry({
    required this.name,
    required this.count,
    required this.time,
    required this.isMissed,
    required this.onTap,
  });

  final String name;
  final int count;
  final String time;
  final bool isMissed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isMissed ? Icons.phone_missed : Icons.phone_callback,
              color: isMissed
                  ? const Color(0xFFFF453A)
                  : const Color(0xFF34C759),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isMissed
                              ? const Color(0xFFFF453A)
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (count > 1) ...[
                        const SizedBox(width: 4),
                        Text(
                          '($count)',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Color(0xFF0A84FF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _VoicemailEntry extends StatefulWidget {
  const _VoicemailEntry({
    required this.name,
    required this.time,
    required this.duration,
    required this.transcript,
    this.isThreat = false,
  });

  final String name;
  final String time;
  final String duration;
  final String transcript;
  final bool isThreat;

  @override
  State<_VoicemailEntry> createState() => _VoicemailEntryState();
}

class _VoicemailEntryState extends State<_VoicemailEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isThreat
        ? const Color(0xFFFF453A).withValues(alpha: 0.4)
        : const Color(0xFF2C2C2E);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isThreat
              ? const Color(0xFF1A0A0A)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.voicemail,
                  color: widget.isThreat
                      ? const Color(0xFFFF453A)
                      : const Color(0xFF34C759),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      color: widget.isThreat
                          ? const Color(0xFFFF453A)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.duration,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.time,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            // Fake waveform bar.
            const SizedBox(height: 8),
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: _WaveformPainter(
                  color: widget.isThreat
                      ? const Color(0xFFFF453A)
                      : const Color(0xFF34C759),
                ),
                size: const Size(double.infinity, 24),
              ),
            ),
            // Transcript (expandable).
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transkrypcja:',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.transcript,
                      style: TextStyle(
                        color: widget.isThreat
                            ? const Color(0xFFFFB1AC)
                            : Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            const SizedBox(height: 4),
            Center(
              child: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white38,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple fake waveform painter — random bars.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = (size.width / 4).floor();
    // Deterministic "random" heights based on position.
    for (var i = 0; i < barCount; i++) {
      final x = i * 4.0 + 2;
      final seed = (i * 7 + 3) % 13;
      final h = (seed / 13) * size.height * 0.8 + size.height * 0.1;
      final top = (size.height - h) / 2;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
