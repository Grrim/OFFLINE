import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// One entry in N.'s browser history.
class BrowserEntry {
  const BrowserEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.timestamp,
    required this.preview,
    this.isPrivate = false,
  });

  final String id;
  final String title;
  final String url;

  /// Human-readable relative timestamp ("Wczoraj, 23:12").
  final String timestamp;

  /// Short snippet shown when the entry is opened.
  final String preview;

  /// Marks entries from the private window — visually hinted.
  final bool isPrivate;
}

/// Browser app state. Tracks which history entries the player has visited.
class BrowserState extends ChangeNotifier {
  BrowserState({PersistenceService? persistence}) : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kVisitedIds = 'game.browser.visited';

  final PersistenceService? _persistence;
  final List<BrowserEntry> _entries = [];
  final Set<String> _visitedIds = {};

  List<BrowserEntry> get entries => List.unmodifiable(_entries);

  /// Whether private mode entries are visible. Persisted under
  /// `game.browser.privateUnlocked`. Toggle via [unlockPrivate].
  bool _privateUnlocked = false;
  bool get isPrivateUnlocked => _privateUnlocked;

  /// Hardcoded password for the private mode. Comes from N.'s
  /// "Hasła Wi-Fi" note (Mruczek = jej kot, 2019 = rok urodzenia).
  /// Hint surfaces in Nieznany dialogue after enough evidence is
  /// gathered.
  static const String _privatePassword = 'mruczek2019';

  /// Wired in main.dart. Called once on first successful private unlock.
  void Function()? onPrivateUnlocked;

  /// Wired from main.dart. Called every time a player visits a browser
  /// entry. Used to award evidence per-page.
  void Function(String entryId)? onEntryVisited;

  /// Try to unlock private mode with the given password. Returns true
  /// on success.
  bool tryUnlockPrivate(String password) {
    if (_privateUnlocked) return true;
    if (password.trim().toLowerCase() != _privatePassword) return false;
    _privateUnlocked = true;
    _persistence?.setBool(_kPrivateUnlocked, true);
    notifyListeners();
    onPrivateUnlocked?.call();
    return true;
  }

  /// Public-only entries (everything where `isPrivate == false`).
  List<BrowserEntry> get publicEntries =>
      _entries.where((e) => !e.isPrivate).toList(growable: false);

  /// Private-only entries (revealed only after [tryUnlockPrivate]).
  List<BrowserEntry> get privateEntries =>
      _entries.where((e) => e.isPrivate).toList(growable: false);

  /// All entries currently visible to the player. Until private mode is
  /// unlocked this returns just the public ones.
  List<BrowserEntry> get visibleEntries =>
      _privateUnlocked ? entries : publicEntries;

  static const String _kPrivateUnlocked = 'game.browser.privateUnlocked';

  bool hasVisited(String id) => _visitedIds.contains(id);

  void markVisited(String id) {
    if (_visitedIds.add(id)) {
      _persistVisited();
      notifyListeners();
      onEntryVisited?.call(id);
    }
  }

  void _persistVisited() {
    _persistence?.setStringList(_kVisitedIds, _visitedIds.toList());
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _visitedIds.addAll(p.getStringList(_kVisitedIds));
    _privateUnlocked = p.getBool(_kPrivateUnlocked);
  }

  void reset() {
    _visitedIds.clear();
    _privateUnlocked = false;
    notifyListeners();
  }

  // ─── Seed ─────────────────────────────────────────────────────

  void _seed() {
    _entries.addAll(const [
      BrowserEntry(
        id: 'krs_helion',
        title: 'KRS - HELION-BUD Sp. z o.o.',
        url: 'rejestr.io/firma/helion-bud',
        timestamp: 'Wczoraj, 22:08',
        preview:
            'Helion-Bud Sp. z o.o.\n'
            'KRS: 0000847211 | NIP: 524-29-87-122\n\n'
            'Forma prawna: Spółka z ograniczoną odpowiedzialnością\n'
            'Kapitał zakładowy: 50.000 PLN\n'
            'Data rejestracji: 14.03.2019\n\n'
            'Wspólnicy:\n'
            '  - Marek N. (49%)\n'
            '  - Tomasz B. (51%)\n\n'
            'PKD główne: 41.20.Z (Roboty budowlane)\n'
            'PKD dodatkowe: 70.22.Z (Konsulting) - dodano 12.07.2025  ← !',
      ),
      BrowserEntry(
        id: 'forum_lokalny',
        title: '"Wycinki w Kabackim - kto tam jest" - Forum Wilanów',
        url: 'forum.wilanow.pl/wycinki-kabackim',
        timestamp: 'Wczoraj, 22:14',
        preview:
            '@LesnyDziadek (przed tyg.):\n'
            'Wczoraj nocą znowu maszyny w lesie. Dzwoniłem na 112, '
            'powiedzieli że "interweniują". Patrol pojechał, wrócił '
            'po 5 min. Nikogo nie zatrzymali.\n\n'
            '@Anonim (przed tyg.):\n'
            'Sąsiad pracuje w Helion-Bud. Mówił że szef jeździ na piwo z '
            'komendantem. Tylko nie pisz że ja powiedziałem.\n\n'
            '@MamaTrzech (4 dni temu):\n'
            'Byłam w komendzie żeby złożyć skargę. Pan oficer mnie wyśmiał '
            'i powiedział że "wycinki są legalne, bo mają papiery". Jakie '
            'papiery? Nie pokazał.',
      ),
      BrowserEntry(
        id: 'ekolog',
        title: 'Stowarzyszenie Strażnicy Lasu - dokumenty',
        url: 'straznicylasu.org/raporty/2026',
        timestamp: 'Wczoraj, 22:33',
        preview:
            'RAPORT 2026/Q1 - REZERWAT LAS KABACKI\n\n'
            'W pierwszym kwartale 2026 odnotowaliśmy wycinkę co najmniej '
            '1.1 ha drzewostanu w sektorach uznawanych za rezerwat ścisły. '
            'Wszystkie zgłoszenia do organów ścigania pozostały bez '
            'reakcji. Otrzymujemy informacje o zorganizowanym charakterze '
            'wycinek (ciężki sprzęt, brak oznakowań, działanie nocne).\n\n'
            'Zwracamy się z prośbą o kontakt do osób posiadających '
            'dokumentację: zdjęcia, nagrania, świadkowie. Sygnał można '
            'przekazać anonimowo.',
      ),
      BrowserEntry(
        id: 'gazeta',
        title: 'Anita Z. - "Cisza w lesie" (zapowiedź)',
        url: 'gazeta.pl/lokalna/cisza-w-lesie',
        timestamp: 'Wczoraj, 23:01',
        preview:
            'CISZA W LESIE - kto chroni wycinki w Kabackim?\n'
            'autor: Anita Z. | publikacja: w przygotowaniu\n\n'
            'Już w sobotę publikujemy reportaż śledczy o wycince w '
            'rezerwacie Las Kabacki. Czy organy ścigania pomagają firmie '
            'budowlanej w nielegalnej działalności? Mamy faktury, mamy '
            'nagrania, mamy świadków.\n\n'
            'Tekst pojawi się tylko w wydaniu papierowym - chcemy uniknąć '
            'presji ze strony zainteresowanych.',
      ),
      BrowserEntry(
        id: 'sygnal',
        title: 'Pobierz Signal - bezpieczna komunikacja',
        url: 'signal.org/download',
        timestamp: 'Wczoraj, 23:05',
        preview:
            'Signal to darmowa, otwartoźródłowa aplikacja do bezpiecznej '
            'komunikacji. Wiadomości i połączenia są szyfrowane end-to-end.\n\n'
            'Pobierz aplikację dla swojego systemu...',
        isPrivate: true,
      ),
      BrowserEntry(
        id: 'skrytka',
        title: 'Skrytki bagażowe Warszawa Centralna - cennik',
        url: 'pkp.pl/dworce/skrytki/warszawa-centralna',
        timestamp: 'Wczoraj, 23:18',
        preview:
            'Skrytki bagażowe na peronie -1\n'
            '24h: 12 PLN | 48h: 22 PLN | 7 dni: 90 PLN\n\n'
            'Numery skrytek: 1-50 (małe), 51-100 (średnie), '
            '101-150 (duże).\n'
            'Płatność: gotówka lub karta. Klucz wydawany przy zamknięciu, '
            'utrata klucza: opłata 200 PLN.',
        isPrivate: true,
      ),
      BrowserEntry(
        id: 'predyspozycje',
        title: 'Co zrobić, jeśli ktoś mnie śledzi?',
        url: 'forumpsychologiczne.pl/sledzenie-co-robic',
        timestamp: 'Wczoraj, 23:42',
        preview:
            'Pytanie:\n'
            'Od kilku dni mam wrażenie że ktoś mnie obserwuje. Wczoraj '
            'samochód stał pod moim domem 2 godziny ze zgaszonymi '
            'światłami. Co mam robić? Bać się, czy to paranoja?\n\n'
            'Odpowiedź eksperta:\n'
            'Jeśli masz konkretne podstawy by sądzić że jesteś śledzona, '
            '**nie ignoruj tego**. Powiedz komuś bliskiemu o swoich '
            'obserwacjach, prowadź notatki (data, godzina, opis), unikaj '
            'wracania do domu tą samą trasą...',
        isPrivate: true,
      ),
      BrowserEntry(
        id: 'centralna',
        title: 'Prokurator dyżurny - Prokuratura Okręgowa Warszawa',
        url: 'po.warszawa.gov.pl/dyzurny',
        timestamp: 'Wczoraj, 23:51',
        preview:
            'PROKURATOR DYŻURNY\n'
            'Prokuratura Okręgowa w Warszawie\n'
            'ul. Chocimska 28, 00-791 Warszawa\n\n'
            'Przyjmowanie zgłoszeń: 24h, 7 dni w tygodniu\n'
            'Wejście od strony ul. Spacerowej (nocą — domofon).\n\n'
            'Możliwość złożenia zawiadomienia o przestępstwie:\n'
            '- ustnie do protokołu\n'
            '- pisemnie (formularz w sekretariacie)\n'
            '- z dowodami w formie elektronicznej (USB, e-mail)\n\n'
            'UWAGA: w sprawach dotyczących funkcjonariuszy Policji '
            'sprawę prowadzi automatycznie Wydział Spraw Wewnętrznych '
            '(niezależny od komend lokalnych).',
        isPrivate: true,
      ),
    ]);
  }
}
