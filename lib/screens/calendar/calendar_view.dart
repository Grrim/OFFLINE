import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/l10n_service.dart';
import '../../widgets/fragment_hotspot.dart';
import '../../widgets/status_bar.dart';

/// Calendar app — shows N.'s last week as a timeline of events.
/// Tapping an event shows a detailed narrative description.
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dialogues = L10nService.instance.dialogues['calendar'] as Map<String, dynamic>? ?? {};

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
                  Text(
                    l10n.calendarTitle,
                    style: const TextStyle(
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
                    l10n.calendarLastWeek,
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
                children: [
                  _CalendarEvent(
                    day: 'Pon, 12 maja',
                    time: '09:00',
                    title: dialogues['mon']?['title'] ?? 'Praca',
                    subtitle: dialogues['mon']?['subtitle'] ?? '',
                    detail: dialogues['mon']?['detail'] ?? '',
                    color: const Color(0xFF34C759),
                  ),
                  _CalendarEvent(
                    day: 'Wt, 13 maja',
                    time: '16:00',
                    title: dialogues['tue']?['title'] ?? 'Zakupy',
                    subtitle: dialogues['tue']?['subtitle'] ?? '',
                    detail: dialogues['tue']?['detail'] ?? '',
                    color: const Color(0xFF8E8E93),
                  ),
                  _CalendarEvent(
                    day: 'Śr, 14 maja',
                    time: '17:22',
                    title: dialogues['wed']?['title'] ?? 'Selfie',
                    subtitle: dialogues['wed']?['subtitle'] ?? '',
                    detail: dialogues['wed']?['detail'] ?? '',
                    color: const Color(0xFFFF9F0A),
                  ),
                  _CalendarEvent(
                    day: 'Czw, 15 maja',
                    time: '22:00',
                    title: dialogues['thu']?['title'] ?? 'Samochód',
                    subtitle: dialogues['thu']?['subtitle'] ?? '',
                    detail: dialogues['thu']?['detail'] ?? '',
                    color: const Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  _CalendarEvent(
                    day: 'Pt, 16 maja',
                    time: '08:00',
                    title: dialogues['fri_work']?['title'] ?? 'Biuro',
                    subtitle: dialogues['fri_work']?['subtitle'] ?? '',
                    detail: dialogues['fri_work']?['detail'] ?? '',
                    color: const Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  FragmentHotspot(
                    fragmentId: 'frag_meeting',
                    child: _CalendarEvent(
                      day: 'Pt, 16 maja',
                      time: '14:00',
                      title: dialogues['fri_meeting']?['title'] ?? 'Spotkanie',
                      subtitle: dialogues['fri_meeting']?['subtitle'] ?? '',
                      detail: dialogues['fri_meeting']?['detail'] ?? '',
                      color: const Color(0xFFFF453A),
                      isAlert: true,
                    ),
                  ),
                  _CalendarEvent(
                    day: 'Sob, 17 maja',
                    time: '23:45',
                    title: dialogues['sat_photo']?['title'] ?? 'Zdjęcie',
                    subtitle: dialogues['sat_photo']?['subtitle'] ?? '',
                    detail: dialogues['sat_photo']?['detail'] ?? '',
                    color: const Color(0xFF0A84FF),
                  ),
                  _CalendarEvent(
                    day: 'Sob, 17 maja',
                    time: '23:51',
                    title: dialogues['sat_note']?['title'] ?? 'Notatka',
                    subtitle: dialogues['sat_note']?['subtitle'] ?? '',
                    detail: dialogues['sat_note']?['detail'] ?? '',
                    color: const Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      l10n.calendarNoMoreEvents,
                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
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
    required this.detail,
    required this.color,
    this.isAlert = false,
  });

  final String day;
  final String time;
  final String title;
  final String subtitle;
  final String detail;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => _showDetail(context),
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
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.calendarEventDetail,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 4),
              Text('$day · $time', style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w500,
              )),
              const SizedBox(height: 20),
              Text(
                detail.isNotEmpty ? detail : subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
