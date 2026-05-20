import 'package:flutter/material.dart';

import '../services/persistence_service.dart';

/// Metadata for one ending screen.
class GameEnding {
  const GameEnding({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
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
      accentColor: Color(0xFFFF453A),
      icon: Icons.gpp_bad,
    ),
    'escape': GameEnding(
      id: 'escape',
      title: 'ZAKOŃCZENIE 2: UCIECZKA',
      subtitle: 'Gra toczy się dalej.',
      accentColor: Color(0xFF34C759),
      icon: Icons.directions_run,
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
