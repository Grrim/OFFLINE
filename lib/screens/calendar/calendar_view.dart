import 'package:flutter/material.dart';

import '../../widgets/status_bar.dart';

/// Calendar app — shows N.'s last week as a timeline of events.
/// Read-only, no interaction. Builds the narrative timeline for the player.
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

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
                        color: Color(0xFFFF453A), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Kalendarz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Text(
                    'Maj 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ostatni tydzień',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CalendarEvent(
                    day: 'Pon, 12 maja',
                    time: '09:00',
                    title: 'Praca — biuro',
                    subtitle: 'Normalny dzień',
                    color: Color(0xFF34C759),
                  ),
                  _CalendarEvent(
                    day: 'Wt, 13 maja',
                    time: '16:00',
                    title: 'Zakupy',
                    subtitle: 'mleko, pomidory, karma dla Mruczka',
                    color: Color(0xFF8E8E93),
                  ),
                  _CalendarEvent(
                    day: 'Śr, 14 maja',
                    time: '17:22',
                    title: 'Selfie — Plac Zbawiciela',
                    subtitle: 'Spotkanie z przyjaciółką?',
                    color: Color(0xFFFF9F0A),
                  ),
                  _CalendarEvent(
                    day: 'Czw, 15 maja',
                    time: '22:00',
                    title: '⚠️ Samochód pod domem',
                    subtitle: 'Zgaszone światła, 2h pod oknem',
                    color: Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  _CalendarEvent(
                    day: 'Pt, 16 maja',
                    time: '08:00',
                    title: 'Nie pojawiła się w pracy',
                    subtitle: 'Biuro: "nie widzieliśmy jej od rana"',
                    color: Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  _CalendarEvent(
                    day: 'Pt, 16 maja',
                    time: '14:00',
                    title: 'Spotkanie: Anita Z. (Gazeta)',
                    subtitle: 'Kawiarnia Relaks — NIEOBECNA',
                    color: Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  _CalendarEvent(
                    day: 'Sob, 17 maja',
                    time: '23:45',
                    title: '📷 Zdjęcie — Las Kabacki',
                    subtitle: 'Ostatnie zdjęcie w galerii',
                    color: Color(0xFF0A84FF),
                  ),
                  _CalendarEvent(
                    day: 'Sob, 17 maja',
                    time: '23:51',
                    title: '📝 Notatka: "W RAZIE ZNIKNIĘCIA"',
                    subtitle: 'Ostatnia aktywność na telefonie',
                    color: Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Brak dalszych wpisów.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarEvent extends StatelessWidget {
  const _CalendarEvent({
    required this.day,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isAlert = false,
  });

  final String day;
  final String time;
  final String title;
  final String subtitle;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line.
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: isAlert
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 50,
                  color: const Color(0xFF2C2C2E),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAlert
                    ? color.withValues(alpha: 0.08)
                    : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(10),
                border: isAlert
                    ? Border.all(color: color.withValues(alpha: 0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isAlert ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
