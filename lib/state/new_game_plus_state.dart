import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Persistent meta-progression for New Game+.
///
/// Tracks:
/// - `runCount` — how many times the player has completed an ending.
///   Increments on every ending dispatch (incl. early ones like CAUGHT).
/// - `isPlusActive` — whether the *current* run is an NG+ session.
///   Set when the player chooses "kontynuuj NG+" on a fresh boot
///   after their first completion.
/// - `previousEndings` — list of all endings reached, in order. The
///   meta-narrator (Nieznany) references these in NG+ runs to make
///   the loop tangible.
/// - `cycleHinted` — whether Nieznany has dropped his "loop" hint that
///   unlocks the CYKL ending choice. Idempotent flag.
///
/// Persisted under `meta.*` so it survives "Resetuj rozgrywkę" — NG+
/// is by definition cross-run state.
class NewGamePlusState extends ChangeNotifier {
  NewGamePlusState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kRunCount = 'meta.ngp.runCount';
  static const String _kIsPlusActive = 'meta.ngp.isPlusActive';
  static const String _kPreviousEndings = 'meta.ngp.previousEndings';
  static const String _kCycleHinted = 'meta.ngp.cycleHinted';

  final PersistenceService? _persistence;

  int _runCount = 0;
  bool _isPlusActive = false;
  final List<String> _previousEndings = [];
  bool _cycleHinted = false;

  int get runCount => _runCount;
  bool get isPlusActive => _isPlusActive;
  List<String> get previousEndings =>
      List.unmodifiable(_previousEndings);
  bool get cycleHinted => _cycleHinted;

  /// True if the player is eligible to start an NG+ run on next launch.
  /// Equivalent to `runCount > 0`.
  bool get canStartPlus => _runCount > 0;

  /// True when the player has reached the end of the second meta-loop —
  /// CYKL becomes available after at least 2 prior endings AND being
  /// in an active NG+ run.
  bool get cycleAvailable =>
      _isPlusActive && _runCount >= 2 && _cycleHinted;

  /// Activate NG+ for the current run. Called from the boot decision
  /// screen after the player picks "kontynuuj NG+".
  void enterPlusRun() {
    if (_isPlusActive) return;
    _isPlusActive = true;
    _persistence?.setBool(_kIsPlusActive, true);
    notifyListeners();
  }

  /// Leave NG+ (called when the player resets via Settings or starts
  /// a fresh non-plus run).
  void leavePlusRun() {
    if (!_isPlusActive) return;
    _isPlusActive = false;
    _cycleHinted = false;
    _persistence?.setBool(_kIsPlusActive, false);
    _persistence?.setBool(_kCycleHinted, false);
    notifyListeners();
  }

  /// Record an ending. Bumps `runCount` and appends to `previousEndings`.
  /// Idempotent within a single run — only fires when the ending id
  /// differs from the most recent entry.
  void recordEnding(String endingId) {
    if (_previousEndings.isNotEmpty &&
        _previousEndings.last == endingId) {
      return;
    }
    _previousEndings.add(endingId);
    _runCount += 1;
    _persistence?.setInt(_kRunCount, _runCount);
    _persistence?.setStringList(_kPreviousEndings, _previousEndings);
    notifyListeners();
  }

  /// Mark that Nieznany has hinted at the loop ("już to widziałeś,
  /// prawda?"). After this, CYKL becomes a reachable ending in the
  /// current NG+ run.
  void markCycleHinted() {
    if (_cycleHinted) return;
    _cycleHinted = true;
    _persistence?.setBool(_kCycleHinted, true);
    notifyListeners();
  }

  /// Wipe meta-progression. Used by "factory reset" (the deep reset
  /// from EndingState.resetDiscoveryToo's caller path) — NOT by the
  /// regular gameplay reset.
  void resetAll() {
    _runCount = 0;
    _isPlusActive = false;
    _previousEndings.clear();
    _cycleHinted = false;
    _persistence?.remove(_kRunCount);
    _persistence?.remove(_kIsPlusActive);
    _persistence?.remove(_kPreviousEndings);
    _persistence?.remove(_kCycleHinted);
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _runCount = p.getInt(_kRunCount);
    _isPlusActive = p.getBool(_kIsPlusActive);
    _cycleHinted = p.getBool(_kCycleHinted);
    _previousEndings.addAll(p.getStringList(_kPreviousEndings));
  }
}
