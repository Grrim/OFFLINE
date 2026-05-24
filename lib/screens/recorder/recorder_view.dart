import 'package:flutter/material.dart';

import '../../widgets/status_bar.dart';

/// Voice recorder app — shows N.'s audio recordings as a list.
/// Tapping reveals a "transcript" with typewriter-style progressive reveal.
/// Contains critical clues (timestamps, names, locations).
class RecorderView extends StatelessWidget {
  const RecorderView({super.key});

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
                    'Dyktafon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _RecordingTile(
                    title: 'Nagranie 003',
                    date: '10 maja 2026, 22:14',
                    duration: '6:48',
                    location: 'Parking hipermarket',
                    transcript:
                        'Jestem na parkingu za hipermarketem. Jest 22:14. '
                        'Czarny SUV już stoi — rejestracja WI 38274. '
                        'K. przyjechał sam, jak zawsze. Czekam.\n\n'
                        '[szum, kroki na żwirze]\n\n'
                        'Podchodzi do SUV-a. Otwiera okno. Widzę kopertę. '
                        'Gazeta codzienna — Rzeczpospolita, chyba. '
                        'Przekazanie trwa może 10 sekund.\n\n'
                        '[cisza]\n\n'
                        'K. zostaje. Pali papierosa. SUV odjeżdża. '
                        'Mam to. Trzecie nagranie. Trzecia koperta.\n\n'
                        'Kwota na fakturze: 14 tysięcy. Jak ostatnio.',
                    isImportant: true,
                  ),
                  _RecordingTile(
                    title: 'Nagranie 002',
                    date: '25 kwietnia 2026, 22:08',
                    duration: '4:22',
                    location: 'Parking hipermarket',
                    transcript:
                        'Drugie nagranie. Ten sam parking. K. i ten sam '
                        'czarny SUV. Tym razem widzę twarz kierowcy — '
                        'to Tomasz B., wspólnik Helion-Bud (51% udziałów, '
                        'sprawdziłam w KRS).\n\n'
                        'Koperta jest grubsza niż ostatnio. K. chowa ją '
                        'do wewnętrznej kieszeni kurtki.\n\n'
                        'Muszę to skończyć. Jeszcze jedno nagranie i idę '
                        'do Anity.',
                  ),
                  _RecordingTile(
                    title: 'Nagranie 001',
                    date: '28 marca 2026, 14:22',
                    duration: '3:15',
                    location: 'Stacja Orlen, Mokotów',
                    transcript:
                        'Pierwsze nagranie. Stacja benzynowa na Mokotowie. '
                        'Jest 14:22. Widzę K. — komendant powiatowy. '
                        'Wszyscy mówią na niego Szeryf.\n\n'
                        'Podjeżdża czarny SUV. Nie widzę rejestracji. '
                        'K. podchodzi do okna. Ktoś podaje mu coś — '
                        'wygląda jak koperta w gazecie.\n\n'
                        'Nie mam jeszcze dowodu. Ale wiem co widziałam.\n\n'
                        '[N.: to był początek. 14:22. Zapamiętam tę godzinę.]',
                    isImportant: true,
                  ),
                  _RecordingTile(
                    title: 'Notatka głosowa',
                    date: '16 maja 2026, 23:40',
                    duration: '0:34',
                    location: 'Dom',
                    transcript:
                        '[szept, ciężki oddech]\n\n'
                        'Ktoś jest pod domem. Ten sam samochód co wczoraj. '
                        'Zgaszone światła. Nie ruszam się.\n\n'
                        'Jeśli mi się coś stanie — wszystko jest w skrytce '
                        '14B na dworcu. Klucz w doniczce.\n\n'
                        'Mamo, przepraszam.\n\n'
                        '[koniec nagrania]',
                    isImportant: true,
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

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({
    required this.title,
    required this.date,
    required this.duration,
    required this.location,
    required this.transcript,
    this.isImportant = false,
  });

  final String title;
  final String date;
  final String duration;
  final String location;
  final String transcript;
  final bool isImportant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _TranscriptScreen(
            title: title,
            date: date,
            duration: duration,
            location: location,
            transcript: transcript,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isImportant
              ? const Color(0xFFFF453A).withValues(alpha: 0.06)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: isImportant
              ? Border.all(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF453A).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mic, color: Color(0xFFFF453A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 2),
                  Text('$date · $duration', style: const TextStyle(
                    color: Colors.white54, fontSize: 12,
                  )),
                  Text(location, style: const TextStyle(
                    color: Colors.white38, fontSize: 11,
                  )),
                ],
              ),
            ),
            const Icon(Icons.play_arrow, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}

class _TranscriptScreen extends StatelessWidget {
  const _TranscriptScreen({
    required this.title,
    required this.date,
    required this.duration,
    required this.location,
    required this.transcript,
  });

  final String title;
  final String date;
  final String duration;
  final String location;
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFFFF453A), size: 22),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(title, style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600,
                        )),
                        Text('$date · $duration', style: const TextStyle(
                          color: Colors.white54, fontSize: 11,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            // Fake waveform.
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('▶  TRANSKRYPCJA',
                    style: TextStyle(color: Colors.white38, fontSize: 12,
                        letterSpacing: 1)),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Text(
                  transcript,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
