import 'package:flutter/material.dart';

import '../services/persistence_service.dart';

/// Metadata for one ending screen.
class GameEnding {
  const GameEnding({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.epilogue,
    required this.accentColor,
    required this.icon,
    this.secret = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String epilogue;
  final Color accentColor;
  final IconData icon;

  /// If true, the title and subtitle are hidden in the gallery until
  /// the player has discovered this ending. Used for CYKL — only
  /// reachable in New Game+.
  final bool secret;
}

/// Tracks the climax / ending picker state.
///
/// When [activeEnding] is non-null, the phone shell mounts a fullscreen
/// overlay above everything else.
class EndingState extends ChangeNotifier {
  EndingState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kActiveEnding = 'game.ending.activeId';
  static const String _kDiscovered = 'game.ending.discovered';

  final PersistenceService? _persistence;

  static const Map<String, GameEnding> catalog = {
    'caught': GameEnding(
      id: 'caught',
      title: 'ZŁAPANY',
      subtitle: 'Trzeba było nie kłamać.',
      epilogue: 'Samochód podjechał po 4 minuty. Zabrali telefon. '
          'Zabrali ciebie.\n\n'
          'Helion-Bud kontynuuje wycinki. Komendant K. dostał awans. '
          'Mama N. wciąż dzwoni na numer, który już nie istnieje.\n\n'
          'Nikt nigdy nie znajdzie tego telefonu.\n'
          'Nikt nigdy nie znajdzie N.',
      accentColor: Color(0xFFFF453A),
      icon: Icons.gpp_bad,
    ),
    'escape': GameEnding(
      id: 'escape',
      title: 'UCIECZKA',
      subtitle: 'Biegasz. Oni też.',
      epilogue: 'Uciekłeś z telefonem w kieszeni. Szeryf wie, że masz '
          'dowody. Wie, jak wyglądasz.\n\n'
          'N. wciąż jest zaginiona. Anita czeka na materiały, które '
          'nigdy nie dotarły. Mama płacze co noc.\n\n'
          'Masz wszystko, żeby to zakończyć.\n'
          'Pytanie: czy ktoś cię znajdzie pierwszy?',
      accentColor: Color(0xFF34C759),
      icon: Icons.directions_run,
    ),
    'truth': GameEnding(
      id: 'truth',
      title: 'PRAWDA',
      subtitle: 'Jutro rano cała Polska się dowie.',
      epilogue: 'Artykuł Anity Z. trafił do druku o 6:00. Pierwsza '
          'strona. Tytuł: "CISZA W LESIE".\n\n'
          'O 8:00 prokuratura wszczęła śledztwo. O 9:00 komendant K. '
          'został zawieszony. O 12:00 Helion-Bud wydał oświadczenie: '
          '"Nie komentujemy."\n\n'
          'N. wciąż nie odnaleziono.\n'
          'Ale teraz szukają ją wszyscy.',
      accentColor: Color(0xFFFFCC00),
      icon: Icons.article,
    ),
    'dawn': GameEnding(
      id: 'dawn',
      title: 'ŚWIT',
      subtitle: 'Telefon dzwoni. To prokurator.',
      epilogue: 'Prokurator dyżurny przyjął materiały o 5:48. Wydział '
          'Spraw Wewnętrznych ruszył natychmiast.\n\n'
          'O 7:00 CBŚP weszło do siedziby Helion-Bud. O 7:15 '
          'komendant K. został zatrzymany w drodze do pracy. '
          'Nie zdążył nawet zadzwonić po prawnika.\n\n'
          'O 9:23 znaleziono N. Żywą. W piwnicy magazynu w sektorze '
          'C-2.\n\n'
          'Pierwszą rzeczą, którą powiedziała, było:\n'
          '"Wiedziałam, że ktoś znajdzie ten telefon."',
      accentColor: Color(0xFF5AC8FA),
      icon: Icons.wb_twilight,
    ),
    'corruption': GameEnding(
      id: 'corruption',
      title: 'KORUPCJA',
      subtitle: 'Każdy ma swoją cenę.',
      epilogue: 'Wziąłeś kopertę. 50 tysięcy gotówką, owinięte gazetą '
          'codzienną. Tak jak Komendant K. brał co miesiąc.\n\n'
          'N. nigdy nie wraca. Mama N. dostaje anonimowy telefon: '
          '"Wyjechała za granicę. Niech już Pani nie szuka."\n\n'
          'Anita Z. przestaje wierzyć w pisanie reportaży. '
          'Helion-Bud wycina sektor D-1 w sierpniu.\n\n'
          'Telefon N. trafia do śmietnika za stacją.\n'
          'Twój nowy telefon dzwoni czasem nieznanym numerem.\n'
          'Nie odbierasz.',
      accentColor: Color(0xFF8E6E1A),
      icon: Icons.attach_money,
    ),
    'solitude': GameEnding(
      id: 'solitude',
      title: 'SAMOTNIA',
      subtitle: 'Nikt cię nie wysłuchał. Nikt cię nie usłyszał.',
      epilogue: 'Nie zaufałeś Mamie. Nie zaufałeś Anicie. Nie zaufałeś '
          'Tomaszowi. Każda wiadomość, którą wysłałeś, była zimniejsza '
          'od poprzedniej.\n\n'
          'Bateria spada do 1%. Telefon gaśnie.\n\n'
          'Siedzisz w ciemności z urządzeniem, które już nic nie wyświetli. '
          'Anita publikuje tekst bez Twoich materiałów. Jest słaby. '
          'Komendant K. w ogóle nie reaguje. Helion-Bud wydaje '
          'oświadczenie: "Pani N. opuściła kraj z własnej woli."\n\n'
          'Jutro rano jest jak każde inne. Tylko Mruczek czeka pod drzwiami.',
      accentColor: Color(0xFF3A3A3C),
      icon: Icons.do_not_disturb_on,
    ),
    'cycle': GameEnding(
      id: 'cycle',
      title: 'CYKL',
      subtitle: 'Zaczyna się znowu.',
      epilogue: 'Nieznany pisze:\n\n'
          '"Wiedziałem, że wrócisz. Zawsze wracają. Czasem to są '
          'dziennikarze, czasem aktywiści, czasem przypadkowi ludzie '
          'którzy znaleźli jej telefon na chodniku.\n\n'
          'Ale telefon nie pamięta nas między pętlami. To my pamiętamy.\n\n'
          'Helion-Bud, komendant K., Mama N. — to nie były Pani z gazety, '
          'to nie ich córka. To była statystyka. Setki spraw rozpoczętych '
          'w piątek wieczorem, zamykanych w niedzielę nad ranem.\n\n'
          'Tym razem zrobisz to lepiej? Może. A może odłożysz telefon '
          'i pójdziesz spać. Sąsiedzi w bloku obok też tak zrobili.\n\n'
          'Do następnego razu."\n\n'
          '[Telefon się resetuje. Bateria wraca na 37%. Las Kabacki '
          'znowu dymi w oddali.]',
      accentColor: Color(0xFF6E0F0F),
      icon: Icons.refresh,
      secret: true,
    ),
    'witness': GameEnding(
      id: 'witness',
      title: 'ŚWIADEK',
      subtitle: 'Zeznawasz publicznie. Pod własnym nazwiskiem.',
      epilogue: 'O 11:30 stajesz przed kamerami w gmachu prokuratury. '
          'Nie zasłaniasz twarzy. Mówisz powoli, czyta z notatek '
          'które złożyłeś.\n\n'
          'Powtarzasz nazwiska: Komendant K., Tomasz B., wspólnik '
          'spółki Helion-Bud, oraz dwie kolejne osoby z Komendy '
          'Powiatowej, których N. zidentyfikowała w plikach.\n\n'
          'O 14:00 tego samego dnia czterech funkcjonariuszy zostaje '
          'zatrzymanych w miejscu pracy. Helion-Bud Sp. z o.o. zostaje '
          'objęty kontrolą podatkową i zabezpieczeniem majątkowym.\n\n'
          'Rok później Anita Z. dostaje Nagrodę Grand Press. '
          'W swojej mowie wymienia twoje imię.\n\n'
          'Mama N. wciąż nie wie, gdzie jest jej córka. '
          'Ale wiesz, że szukają jej teraz wszyscy — i to się liczy.',
      accentColor: Color(0xFF34C759),
      icon: Icons.record_voice_over,
    ),
    'shadow': GameEnding(
      id: 'shadow',
      title: 'CIEŃ',
      subtitle: 'Anonimowy informator. Bez twarzy. Bez śladu.',
      epilogue: 'Wybierasz drugą drogę: depozyt anonimowy do prokuratury, '
          'kopia szyfrowana do Anity, wszystko przez tor i Signal.\n\n'
          'Sprawa Helion-Bud trafia do mediów dopiero w sierpniu. '
          'Bez pierwszej strony, bez nazwisk, bez konferencji prasowej. '
          'Komendant K. dostaje przeniesienie służbowe. '
          'Tomasz B. wycofuje udziały, sprzedaje firmę córce.\n\n'
          'Las Kabacki sektor C-2 — prokurator wstrzymuje wycinki, '
          'ale dochodzenie jest powolne. Powolne, ale idzie.\n\n'
          'Zostawiłeś telefon w skrytce na dworcu. Nikt nie wie, że to '
          'byłeś ty. Nikt nigdy się nie dowie.\n\n'
          'N. nie wraca. Ale jej praca tak.\n'
          'A ty wracasz do swojego życia, którego nikt już nie obserwuje.',
      accentColor: Color(0xFF8E8E93),
      icon: Icons.visibility_off,
    ),
  };

  GameEnding? _active;
  GameEnding? get activeEnding => _active;

  /// IDs of endings the player has reached at least once across runs.
  /// Persisted under `game.ending.discovered`. Used by the gallery
  /// view to show known/unknown endings.
  final Set<String> _discovered = {};
  Set<String> get discoveredEndings => Set.unmodifiable(_discovered);

  bool isDiscovered(String endingId) => _discovered.contains(endingId);

  /// True after at least one ending has been reached. Drives the
  /// "Endings gallery" entrypoint visibility.
  bool get hasAnyDiscovered => _discovered.isNotEmpty;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final list = p.getStringList(_kActiveEnding);
    if (list.isNotEmpty) {
      _active = catalog[list.first];
    }
    _discovered.addAll(p.getStringList(_kDiscovered));
  }

  void trigger(String endingId) {
    final ending = catalog[endingId];
    if (ending == null) return;
    _active = ending;
    _persistence?.setStringList(_kActiveEnding, [endingId]);
    if (_discovered.add(endingId)) {
      _persistence?.setStringList(_kDiscovered, _discovered.toList());
    }
    notifyListeners();
  }

  /// In-memory reset only — `_discovered` stays. The gallery is a
  /// permanent meta-progression record across the whole user lifetime.
  /// To wipe it, use [resetDiscoveryToo].
  void reset() {
    _active = null;
    notifyListeners();
  }

  /// Wipe both the active ending AND the discovered set. Used by
  /// "factory reset" not the regular "Resetuj rozgrywkę" button.
  void resetDiscoveryToo() {
    _active = null;
    _discovered.clear();
    _persistence?.remove(_kDiscovered);
    notifyListeners();
  }
}
