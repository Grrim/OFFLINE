import 'package:flutter/material.dart';

import '../../widgets/status_bar.dart';

/// Maps app — shows N.'s significant locations as a list with
/// "last visited" timestamps. No actual map rendering (would require
/// Google Maps API), but the list format feels like a "Significant
/// Locations" privacy screen on iOS.
class MapsView extends StatelessWidget {
  const MapsView({super.key});

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
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Ważne miejsca',
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
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Color(0xFFFF453A), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ostatnia znana lokalizacja: Las Kabacki, 17.05.2026 23:45',
                        style: TextStyle(
                          color: Color(0xFFFF453A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _LocationEntry(
                    name: 'Dom',
                    address: 'ul. Puławska 142/14, Warszawa',
                    visits: '347 wizyt',
                    lastVisit: '17 maja, 18:30',
                    icon: Icons.home,
                    color: Color(0xFF34C759),
                  ),
                  _LocationEntry(
                    name: 'Praca',
                    address: 'ul. Marszałkowska 89, Warszawa',
                    visits: '124 wizyty',
                    lastVisit: '15 maja, 17:00',
                    icon: Icons.work,
                    color: Color(0xFF0A84FF),
                  ),
                  _LocationEntry(
                    name: 'Cafe Relaks',
                    address: 'ul. Mokotowska 17, Warszawa',
                    visits: '23 wizyty',
                    lastVisit: '16 maja, 14:22',
                    icon: Icons.local_cafe,
                    color: Color(0xFFFF9F0A),
                  ),
                  _LocationEntry(
                    name: 'Las Kabacki — sektor C-2',
                    address: 'Las Kabacki, Warszawa-Ursynów',
                    visits: '3 wizyty',
                    lastVisit: '17 maja, 23:45',
                    icon: Icons.forest,
                    color: Color(0xFFFF453A),
                    isAlert: true,
                  ),
                  _LocationEntry(
                    name: 'Parking — hipermarket Mokotów',
                    address: 'ul. Wołoska 12, Warszawa',
                    visits: '4 wizyty',
                    lastVisit: '10 maja, 22:14',
                    icon: Icons.local_parking,
                    color: Color(0xFF8E8E93),
                  ),
                  _LocationEntry(
                    name: 'Dworzec Warszawa Centralna',
                    address: 'Al. Jerozolimskie 54, Warszawa',
                    visits: '2 wizyty',
                    lastVisit: '16 maja, 23:20',
                    icon: Icons.train,
                    color: Color(0xFF5AC8FA),
                  ),
                  _LocationEntry(
                    name: 'Plac Zbawiciela',
                    address: 'Plac Zbawiciela, Warszawa',
                    visits: '8 wizyt',
                    lastVisit: '14 maja, 17:22',
                    icon: Icons.place,
                    color: Color(0xFFFFCC00),
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

class _LocationEntry extends StatelessWidget {
  const _LocationEntry({
    required this.name,
    required this.address,
    required this.visits,
    required this.lastVisit,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String name;
  final String address;
  final String visits;
  final String lastVisit;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert
            ? color.withValues(alpha: 0.06)
            : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(
                  color: isAlert ? color : Colors.white,
                  fontSize: 14,
                  fontWeight: isAlert ? FontWeight.w700 : FontWeight.w500,
                )),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(
                  color: Colors.white54, fontSize: 12,
                )),
                const SizedBox(height: 2),
                Text('$visits · Ostatnio: $lastVisit', style: const TextStyle(
                  color: Colors.white38, fontSize: 11,
                )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
        ],
      ),
    );
  }
}
