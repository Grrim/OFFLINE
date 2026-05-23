import 'package:flutter/material.dart';

import '../services/persistence_service.dart';

/// One document in the Files app. Mostly read-only; the player browses
/// the contents to assemble the picture of N.'s investigation.
class GameFile {
  const GameFile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateString,
    required this.icon,
    required this.iconColor,
    required this.body,
    this.isMonospace = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String dateString;
  final IconData icon;
  final Color iconColor;
  final String body;

  /// Render the body in a monospace font (for invoices, transcripts).
  final bool isMonospace;
}

/// Files app state. Tracks which documents the player has opened.
class FilesState extends ChangeNotifier {
  FilesState({PersistenceService? persistence}) : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kOpenedIds = 'files.opened';

  final PersistenceService? _persistence;
  final List<GameFile> _files = [];
  final Set<String> _openedIds = {};

  List<GameFile> get files => List.unmodifiable(_files);

  bool hasOpened(String id) => _openedIds.contains(id);

  /// Number of documents the player hasn't seen yet — drives the home
  /// icon badge.
  int get unreadCount =>
      _files.where((f) => !_openedIds.contains(f.id)).length;

  /// Number of opened documents — drives the chapter 2 trigger.
  int get openedCount => _openedIds.length;

  /// Wired from main.dart. Called once when [openedCount] crosses the
  /// chapter-2 threshold (≥4 files opened).
  void Function()? onChapter2Threshold;

  /// Wired from main.dart. Called when the player opens their first file.
  void Function()? onFirstFileOpened;

  static const int chapter2OpenThreshold = 4;
  bool _thresholdFired = false;
  bool _firstFileFired = false;

  void markOpened(String id) {
    if (_openedIds.add(id)) {
      _persistOpened();
      notifyListeners();
      _maybeFireFirstFile();
      _maybeFireThreshold();
    }
  }

  void _maybeFireFirstFile() {
    if (_firstFileFired) return;
    if (_openedIds.length == 1) {
      _firstFileFired = true;
      onFirstFileOpened?.call();
    }
  }

  void _maybeFireThreshold() {
    if (_thresholdFired) return;
    if (_openedIds.length >= chapter2OpenThreshold) {
      _thresholdFired = true;
      onChapter2Threshold?.call();
    }
  }

  GameFile? fileById(String id) {
    for (final f in _files) {
      if (f.id == id) return f;
    }
    return null;
  }

  void _persistOpened() {
    _persistence?.setStringList(_kOpenedIds, _openedIds.toList());
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _openedIds.addAll(p.getStringList(_kOpenedIds));
  }

  void reset() {
    _openedIds.clear();
    _thresholdFired = false;
    _firstFileFired = false;
    notifyListeners();
  }

  // ─── Seed ─────────────────────────────────────────────────────

  void _seed() {
    _files.addAll(const [
      GameFile(
        id: 'faktura_2026_05',
        title: 'Faktura HB-2026-0517.pdf',
        subtitle: 'Helion-Bud Sp. z o.o.',
        dateString: '2 maja 2026',
        icon: Icons.description,
        iconColor: Color(0xFFFF453A),
        isMonospace: true,
        body: '''
================================================
   HELION-BUD Sp. z o.o.
   ul. Modlinska 47, 03-216 Warszawa
   NIP: 524-29-87-122
================================================

FAKTURA VAT  Nr  HB-2026-0517
Data wystawienia:  02.05.2026
Termin platnosci:  do 16.05.2026

Nabywca:
  KOMENDA POWIATOWA POLICJI
  (dane zaslepione - DOSTEP RESTRYKCYJNY)

Pozycja                              Netto      VAT      Brutto
------------------------------------------------------------------
Uslugi konsultingowe w zakresie
ochrony perimetru obiektu w
Lesie Kabackim, maj 2026           12.000,00   2.760,00  14.760,00
------------------------------------------------------------------
RAZEM                              12.000,00   2.760,00  14.760,00

Numer rachunku odbiorcy:
  PL 87 1140 2004 0000 3502 8551 7766

[ N.: TO NIE JEST KONSULTING. PRZECIEZ ON SIEDZI W BIURZE
  KOMENDY. CO MIESIAC TA SAMA KWOTA. NIE ZA USLUGI - ZA CISZE. ]
''',
      ),
      GameFile(
        id: 'faktura_2026_04',
        title: 'Faktura HB-2026-0416.pdf',
        subtitle: 'Helion-Bud Sp. z o.o.',
        dateString: '1 kwietnia 2026',
        icon: Icons.description,
        iconColor: Color(0xFFFF453A),
        isMonospace: true,
        body: '''
================================================
   HELION-BUD Sp. z o.o.
================================================

FAKTURA VAT  Nr  HB-2026-0416
Data wystawienia:  01.04.2026
Termin platnosci:  do 15.04.2026

Pozycja                              Netto      VAT      Brutto
------------------------------------------------------------------
Uslugi konsultingowe w zakresie
ochrony perimetru obiektu w
Lesie Kabackim, kwiecien 2026      12.000,00   2.760,00  14.760,00
------------------------------------------------------------------
RAZEM                              12.000,00   2.760,00  14.760,00

[ N.: trzecia z rzedu na te sama kwote, do tego samego konta.
  Sprawdzilam KRS - "konsulting" to ich jedyna pozaglowna PKD,
  dopisana 3 miesiace temu. ]
''',
      ),
      GameFile(
        id: 'transkrypcja',
        title: 'Transkrypcja_10.05.2026.txt',
        subtitle: 'Nagranie audio · 14:23',
        dateString: '10 maja 2026',
        icon: Icons.text_snippet,
        iconColor: Color(0xFF0A84FF),
        isMonospace: true,
        body: '''
TRANSKRYPCJA NAGRANIA - 10.05.2026
Lokalizacja: parking za hipermarketem, Mokotow
Czas: 22:14 - 22:21
Uczestnicy: GLOS A (komendant K. - "Szeryf"), GLOS B (przedstawiciel HB)

[22:14:08]
GLOS B: ...przyniosles to o czym mowilismy?
GLOS A: Wszystko jest. Tylko nie tutaj. Nie na otwartym.

[22:14:31]
GLOS B: To gdzie? Czas mnie goni, jutro rano wjezdzaja
        maszyny w sektor C-2.
GLOS A: Spokojnie. Jutro zalatwie temat z patrolami.
        Beda omijac C-2 az do polnocy.

[22:15:02]
GLOS B: A ten dziennikarz?
GLOS A: Z Gazety? Mam go na oku. Bawi sie w sledztwo,
        ale to chlopak. Nic nie znajdzie.

[22:15:40]
GLOS B: A ta kobieta? Ta od raportow?
GLOS A: ...widzialem zdjecie. Sprawdzam ja.

[22:16:18]
GLOS B: Nie rob nic glupiego. Sami nikt nie zniknie.
GLOS A: Wiem, wiem. Ale jak bedzie trzeba...
GLOS B: Wtedy gadamy. Nie wczesniej. Daj kopertę.

[Krotka cisza, szelest papieru, 4 sekundy.]

[22:16:55]
GLOS A: 14 tysiecy. Jak ostatnio.
GLOS B: Do widzenia, panie komendancie.

[Koniec nagrania, 22:17:02]

[ N.: nagranie z dyktafonu w torbie - puste opakowanie po
  papierosach. Drugi raz zlapalam ich na tym. Pierwszy raz
  bylo w marcu. Anita ma kopię. ]

[ N.: pierwsze nagranie zrobilam dokladnie 14:22 dnia 28.03.
  Zawsze pamietam te godzine - to byla moja ostatnia spokojna
  niedziela. Jak bedziesz potrzebowala kodu - on jest w tej
  godzinie. ]
''',
      ),
      GameFile(
        id: 'koperty',
        title: 'lista_kopert.numbers',
        subtitle: 'Arkusz · 18 wpisów',
        dateString: '8 maja 2026',
        icon: Icons.table_chart,
        iconColor: Color(0xFF34C759),
        isMonospace: true,
        body: '''
LISTA KOPERTY - HELION-BUD -> KOMENDA
=====================================

DATA          KWOTA       MIEJSCE PRZEKAZANIA      SWIADEK
-------------------------------------------------------------------
2026-02-15    10.000      Stacja Orlen, Mokotow    -
2026-03-12    10.000      Parking Galeria Pn       J.M. (kelner)
2026-03-28    12.000      Las Kabacki, sciezka     -
2026-04-10    12.000      Parking hipermarket      A. (foto)
2026-04-25    12.000      Parking hipermarket      A. (audio)
2026-05-10    14.000      Parking hipermarket      A. (audio)
                                                   <- ostatnie!
-------------------------------------------------------------------
RAZEM:        70.000

UWAGI:
- kazda koperta przelozona w gazete codzienna
- HB zawsze w czarnym SUV-ie BMW (rej. WI 38274)
- K. (Szeryf) zawsze sam, bez kierowcy
- po przekazaniu HB znika w 30s, K. zostaje 5-10min

[ N.: jak juz wszystko wyjdzie, to powinno wystarczyc na
  korupcje przy pelnieniu funkcji + udzielenie pomocy. K. straci
  emeryture i zegar. ]
''',
      ),
      GameFile(
        id: 'mapa_wycinek',
        title: 'mapa_wycinek_2026.txt',
        subtitle: 'Notatka geograficzna',
        dateString: '5 maja 2026',
        icon: Icons.map,
        iconColor: Color(0xFFFF9F0A),
        isMonospace: true,
        body: '''
LAS KABACKI - SEKTORY NIELEGALNYCH WYCINEK 2026
================================================

Sektor A-1 (przy ul. Wandy Rutkiewicz)
  - luty 2026: ~0.4 ha, 80 drzew (sosna, dab)
  - oficjalnie: "wycinka pielegnacyjna"
  - rzeczywiscie: pod plac budowy magazynu HB

Sektor B-3 (na poludnie od stawu Wilanowskiego)
  - marzec 2026: ~0.7 ha, 120 drzew
  - oficjalnie: "stan zagrozenia bezpieczenstwa"
  - rzeczywiscie: przygotowanie pod parking dla TIR-ow

Sektor C-2 (zachodni skraj rezerwatu)
  - maj 2026: WYCINKA W TOKU
  - rozmiar: ~1.2 ha (najwiekszy do tej pory)
  - patrole policji: omijaja teren w godzinach 22:00-06:00
  - tu byla anonimowa skarga z 03.05. - oficjalnie "zbadana,
    nie potwierdzono nieprawidlowosci"

[ N.: bylam tam wczoraj w nocy. C-2. Maja juz przygotowane
  drogi dojazdowe. To nie konsulting, to zorganizowane
  niszczenie rezerwatu. Zdjecie zrobilam o 23:45 - wlasnie
  podjechal pierwszy harvester. ]
''',
      ),
    ]);
  }
}
