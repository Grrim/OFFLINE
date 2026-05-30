import 'package:flutter/material.dart';

import '../services/persistence_service.dart';

/// Static metadata for one achievement.
class GameAchievement {
  const GameAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.secret = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  /// If true, the title and description are hidden until unlocked.
  final bool secret;
}

/// Tracks unlocked achievements.
///
/// 12 achievements covering different play styles. Persistence is
/// cross-run (like [EndingState.discoveredEndings]) — gameplay reset
/// does NOT wipe them.
class AchievementsState extends ChangeNotifier {
  AchievementsState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kUnlocked = 'settings.achievements.unlocked';

  static const Map<String, GameAchievement> catalog = {
    'first_unlock': GameAchievement(
      id: 'first_unlock',
      title: 'Wejście',
      description: 'Odblokuj telefon po raz pierwszy.',
      icon: Icons.lock_open,
      iconColor: Color(0xFF34C759),
    ),
    'curious': GameAchievement(
      id: 'curious',
      title: 'Ciekawski',
      description: 'Otwórz każdą aplikację na ekranie głównym.',
      icon: Icons.explore,
      iconColor: Color(0xFF0A84FF),
    ),
    'detective': GameAchievement(
      id: 'detective',
      title: 'Detektyw',
      description: 'Zdobądź wszystkie dowody (evidenceScore = max).',
      icon: Icons.search,
      iconColor: Color(0xFFFFCC00),
    ),
    'investigator': GameAchievement(
      id: 'investigator',
      title: 'Śledczy',
      description: 'Rozwiąż wszystkie 5 łamigłówek w aplikacjach.',
      icon: Icons.extension,
      iconColor: Color(0xFFFF9F0A),
    ),
    'speedrun': GameAchievement(
      id: 'speedrun',
      title: 'Speedrun',
      description: 'Ukończ grę w mniej niż 10 minut.',
      icon: Icons.timer,
      iconColor: Color(0xFFFF453A),
    ),
    'pacifist': GameAchievement(
      id: 'pacifist',
      title: 'Pacyfista',
      description: 'Ukończ grę bez agresywnej odpowiedzi Szeryfowi.',
      icon: Icons.health_and_safety,
      iconColor: Color(0xFF5AC8FA),
    ),
    'truth_teller': GameAchievement(
      id: 'truth_teller',
      title: 'Świadek',
      description: 'Osiągnij zakończenie PRAWDA.',
      icon: Icons.article,
      iconColor: Color(0xFFFFCC00),
    ),
    'dawn_walker': GameAchievement(
      id: 'dawn_walker',
      title: 'Pierwsze światło',
      description: 'Osiągnij zakończenie ŚWIT.',
      icon: Icons.wb_twilight,
      iconColor: Color(0xFF5AC8FA),
    ),
    'witness_path': GameAchievement(
      id: 'witness_path',
      title: 'Świadek koronny',
      description: 'Osiągnij zakończenie ŚWIADEK.',
      icon: Icons.record_voice_over,
      iconColor: Color(0xFF34C759),
    ),
    'shadow_path': GameAchievement(
      id: 'shadow_path',
      title: 'Cień',
      description: 'Osiągnij zakończenie CIEŃ.',
      icon: Icons.visibility_off,
      iconColor: Color(0xFF8E8E93),
    ),
    'all_endings': GameAchievement(
      id: 'all_endings',
      title: 'Kolekcjoner',
      description: 'Odkryj wszystkie 6 zakończeń.',
      icon: Icons.collections_bookmark,
      iconColor: Color(0xFFAF52DE),
    ),
    'paranoid': GameAchievement(
      id: 'paranoid',
      title: 'Paranoiczny',
      description: 'Przeczytaj każdą wiadomość w każdym wątku.',
      icon: Icons.visibility,
      iconColor: Color(0xFF8E8E93),
    ),
    'mama_loyal': GameAchievement(
      id: 'mama_loyal',
      title: 'Dobry syn',
      description: 'Zaufanie Mamy w finale ≥ 80.',
      icon: Icons.favorite,
      iconColor: Color(0xFFE08AB0),
    ),
    'cycle': GameAchievement(
      id: 'cycle',
      title: 'CYKL',
      description: '???',
      icon: Icons.refresh,
      iconColor: Color(0xFF6E0F0F),
      secret: true,
    ),
  };

  final PersistenceService? _persistence;
  final Set<String> _unlocked = {};

  Set<String> get unlocked => Set.unmodifiable(_unlocked);

  bool isUnlocked(String id) => _unlocked.contains(id);

  int get unlockedCount => _unlocked.length;
  int get totalCount => catalog.length;

  /// Wired by the shell. Fires once per achievement on first unlock.
  void Function(GameAchievement)? onAchievementUnlocked;

  /// Unlock an achievement. Returns true on first unlock (= time to
  /// show toast + sfx).
  bool unlock(String id) {
    if (!catalog.containsKey(id)) {
      assert(false, 'Unknown achievement: $id');
      return false;
    }
    if (!_unlocked.add(id)) return false;
    _persistence?.setStringList(_kUnlocked, _unlocked.toList());
    notifyListeners();
    onAchievementUnlocked?.call(catalog[id]!);
    return true;
  }

  void reset() {
    if (_unlocked.isEmpty) return;
    _unlocked.clear();
    _persistence?.remove(_kUnlocked);
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    for (final id in p.getStringList(_kUnlocked)) {
      if (catalog.containsKey(id)) _unlocked.add(id);
    }
  }
}
