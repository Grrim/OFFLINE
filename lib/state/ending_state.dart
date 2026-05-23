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
      title: 'ZAKOŃCZENIE 1: ZŁAPANY',
      subtitle: 'Trzeba było nie kłamać.',
      epilogue: 'Samochód podjechał po 4 minuty. Telefon N. nigdy nie '
          'trafił do prokuratury. Helion-Bud kontynuuje wycinki do dziś.',
      accentColor: Color(0xFFFF453A),
      icon: Icons.gpp_bad,
    ),
    'escape': GameEnding(
      id: 'escape',
      title: 'ZAKOŃCZENIE 2: UCIECZKA',
      subtitle: 'Gra toczy się dalej.',
      epilogue: 'Uciekłeś z telefonem. Szeryf wie, że masz dowody. '
          'N. wciąż jest zaginiona. Ktoś musi dokończyć to, co zaczęła.',
      accentColor: Color(0xFF34C759),
      icon: Icons.directions_run,
    ),
    'truth': GameEnding(
      id: 'truth',
      title: 'ZAKOŃCZENIE 3: PRAWDA',
      subtitle: 'Jutro o tym napiszą wszystkie gazety.',
      epilogue: 'Artykuł Anity Z. ukazał się w sobotnim wydaniu. '
          'Komendant K. został zawieszony. Prokuratura wszczęła '
          'śledztwo. N. wciąż nie odnaleziono.',
      accentColor: Color(0xFFFFCC00),
      icon: Icons.article,
    ),
    'dawn': GameEnding(
      id: 'dawn',
      title: 'ZAKOŃCZENIE 4: ŚWIT',
      subtitle: 'Telefon dzwoni. To prokurator.',
      epilogue: 'Prokurator dyżurny przyjął materiały o 5:48. O 7:00 '
          'CBŚP weszło do siedziby Helion-Bud. Komendant K. został '
          'zatrzymany w drodze do pracy. N. odnaleziono żywą.',
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
