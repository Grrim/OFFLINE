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
  });

  final String id;
  final String title;
  final String subtitle;
  final String epilogue;
  final Color accentColor;
  final IconData icon;
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

  static const String _kActiveEnding = 'ending.activeId';

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
  };

  GameEnding? _active;
  GameEnding? get activeEnding => _active;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final list = p.getStringList(_kActiveEnding);
    if (list.isNotEmpty) {
      _active = catalog[list.first];
    }
  }

  void trigger(String endingId) {
    final ending = catalog[endingId];
    if (ending == null) return;
    _active = ending;
    _persistence?.setStringList(_kActiveEnding, [endingId]);
    notifyListeners();
  }

  void reset() {
    _active = null;
    notifyListeners();
  }
}
