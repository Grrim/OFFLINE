import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Lightweight key-value store for boolean gameplay flags.
///
/// Use cases:
/// - `puzzle.email_recovered` — set when player reassembles the deleted email
/// - `puzzle.voices_matched` — set when all dictaphone voices are matched
/// - `puzzle.route_reconstructed` — set when map route puzzle is solved
/// - `puzzle.private_unlocked` — set when browser private mode unlocked
/// - `npc.tomasz_summoned` — set when witness thread is active
/// - `chapter.intro_done` — narrative pacing markers
///
/// Flags are persisted under `game.flags.{flagId}` and reset on game
/// reset. Choices in [DialogueChoice] can demand a flag via
/// `requiresFlag` field.
class FlagsState extends ChangeNotifier {
  FlagsState({PersistenceService? persistence}) : _persistence = persistence {
    _load();
  }

  static const String _kPrefix = 'game.flags.';

  final PersistenceService? _persistence;
  final Set<String> _set = {};

  /// True if [flag] is set.
  bool isSet(String flag) => _set.contains(flag);

  /// Set a flag. Idempotent — second call does not notify.
  void set(String flag) {
    if (_set.add(flag)) {
      _persistence?.setBool('$_kPrefix$flag', true);
      notifyListeners();
    }
  }

  /// Clear a single flag.
  void unset(String flag) {
    if (_set.remove(flag)) {
      _persistence?.remove('$_kPrefix$flag');
      notifyListeners();
    }
  }

  /// Snapshot — read-only view.
  Set<String> snapshot() => Set.unmodifiable(_set);

  void reset() {
    if (_set.isEmpty) return;
    _set.clear();
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    for (final key in p.keysWithPrefix(_kPrefix)) {
      final flag = key.substring(_kPrefix.length);
      if (p.getBool(key)) _set.add(flag);
    }
  }
}
