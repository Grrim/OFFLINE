import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Per-NPC trust score in the range -100..+100.
///
/// Trust drives:
/// - Availability of hidden dialogue choices (some choices require
///   `trust >= threshold`).
/// - Tone of NPC responses (cooler/warmer phrasing — implemented at the
///   content layer, not here).
/// - Endings: SOLITUDE fires when all NPCs are very low trust.
///
/// All deltas are clamped into [-100, +100] inclusive. Persistence is
/// per-NPC (`game.trust.{npcId}` keys).
class TrustState extends ChangeNotifier {
  TrustState({PersistenceService? persistence}) : _persistence = persistence {
    _load();
  }

  static const String _kPrefix = 'game.trust.';
  static const int minTrust = -100;
  static const int maxTrust = 100;

  /// NPCs with persisted trust. Other NPCs default to 0 trust.
  static const Set<String> trackedNpcs = {
    'mama',
    'anita',
    'tomasz',
    'nieznany',
  };

  final PersistenceService? _persistence;
  final Map<String, int> _values = {};

  /// Trust value for [npcId]. Returns 0 for any NPC not tracked.
  int get(String npcId) => _values[npcId] ?? 0;

  /// Apply a batch of deltas. Each value is clamped to [-100, +100].
  void apply(Map<String, int> deltas) {
    if (deltas.isEmpty) return;
    var changed = false;
    for (final entry in deltas.entries) {
      final id = entry.key;
      final delta = entry.value;
      if (delta == 0) continue;
      final current = _values[id] ?? 0;
      final next = (current + delta).clamp(minTrust, maxTrust);
      if (next != current) {
        _values[id] = next;
        _persistence?.setInt('$_kPrefix$id', next);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// Set a value directly (clamped). Used by tests; gameplay should
  /// prefer [apply] with deltas.
  @visibleForTesting
  void set(String npcId, int value) {
    final clamped = value.clamp(minTrust, maxTrust);
    if (_values[npcId] == clamped) return;
    _values[npcId] = clamped;
    _persistence?.setInt('$_kPrefix$npcId', clamped);
    notifyListeners();
  }

  /// True if [npcId]'s trust meets [threshold].
  bool meets(String npcId, int threshold) => get(npcId) >= threshold;

  /// True if all tracked NPCs have trust below [threshold].
  /// Used to detect the SOLITUDE ending precondition.
  bool allBelow(int threshold) {
    for (final id in trackedNpcs) {
      if (get(id) >= threshold) return false;
    }
    return true;
  }

  /// Snapshot of all current values (read-only).
  Map<String, int> snapshot() => Map.unmodifiable(_values);

  void reset() {
    if (_values.isEmpty) return;
    _values.clear();
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    for (final id in trackedNpcs) {
      final key = '$_kPrefix$id';
      if (p.containsKey(key)) {
        _values[id] = p.getInt(key);
      }
    }
  }
}
