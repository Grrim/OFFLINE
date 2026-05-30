import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Tracks which evidence items the player has collected and computes
/// their cumulative weight.
///
/// Evidence drives ending availability:
/// - `score >= truthThreshold` → TRUTH path is unlockable.
/// - `score >= dawnThreshold`  → DAWN path is unlockable.
/// - `score < anitaSoftBlock`  → Anita won't believe the player even
///   if they technically reach her dialogue (soft fail).
///
/// Items are addressed by string ID. Weights are defined in [weights].
/// Items with weight 0 are tracked but don't contribute to score
/// (used for narrative-only flags).
class EvidenceState extends ChangeNotifier {
  EvidenceState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kCollected = 'game.evidence.collected';

  /// Master catalog of evidence items with their score weights.
  /// Single source of truth — tests verify all referenced IDs exist here.
  static const Map<String, int> weights = {
    // Photos
    'photo_forest_night': 20,
    'photo_parking': 15,
    'photo_document': 25,
    // Files
    'file_invoice_05': 10,
    'file_invoice_04': 5,
    'file_transcript': 30,
    'file_envelopes': 15,
    'file_map': 10,
    // Recordings
    'recording_001': 15,
    'recording_002': 15,
    'recording_003': 25,
    'voicemail_threat': 10,
    // Email
    'email_anita': 10,
    'email_strazn_lasu': 10,
    'email_recovered': 25,
    // Browser
    'browser_krs': 5,
    'browser_centralna': 15,
    // Puzzle rewards
    'route_reconstructed': 20,
    'voices_matched': 15,
    // Narrative-only flags (no score weight)
    'note_secret': 0,
    'note_plan_b': 0,
  };

  /// Below this score, Anita's TRUTH ending path is unavailable —
  /// she doesn't have enough to publish.
  static const int truthEndingThreshold = 80;

  /// Below this score, Tomasz's DAWN ending path is locked even if
  /// the player knows the password.
  static const int dawnEndingThreshold = 120;

  /// Below this score, the journalist soft-rejects the player.
  static const int anitaSoftBlock = 50;

  final PersistenceService? _persistence;
  final Set<String> _collected = {};

  /// IDs the player has collected.
  Set<String> get collected => Set.unmodifiable(_collected);

  /// Cumulative score across all collected items.
  int get score => _collected.fold(
        0,
        (sum, id) => sum + (weights[id] ?? 0),
      );

  /// Number of collected items (regardless of weight).
  int get count => _collected.length;

  /// Number of items remaining to collect (regardless of weight).
  int get remaining => weights.length - _collected.length;

  /// Whether [id] has been collected.
  bool has(String id) => _collected.contains(id);

  /// True when score crosses the TRUTH threshold.
  bool get canTriggerTruth => score >= truthEndingThreshold;

  /// True when score crosses the DAWN threshold.
  bool get canTriggerDawn => score >= dawnEndingThreshold;

  /// True when Anita would accept the player as a credible source.
  bool get anitaWouldBelieve => score >= anitaSoftBlock;

  /// Mark an item as collected. Idempotent — second call is a no-op.
  /// Returns true on first collection (useful for one-shot rewards
  /// like firing an NPC reaction).
  bool collect(String id) {
    if (_collected.contains(id)) return false;
    if (!weights.containsKey(id)) {
      // Unknown id — guard against typos in content references.
      assert(false, 'Unknown evidence id: $id');
      return false;
    }
    _collected.add(id);
    _persist();
    notifyListeners();
    return true;
  }

  /// Mark several items at once. Returns the set that was newly added.
  Set<String> collectAll(Iterable<String> ids) {
    final added = <String>{};
    for (final id in ids) {
      if (collect(id)) added.add(id);
    }
    return added;
  }

  void reset() {
    if (_collected.isEmpty) return;
    _collected.clear();
    notifyListeners();
  }

  // ---------- Internals ----------

  void _persist() {
    _persistence?.setStringList(_kCollected, _collected.toList());
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final list = p.getStringList(_kCollected);
    for (final id in list) {
      // Drop entries that are no longer in the catalog (e.g. content
      // refactor renamed an evidence id).
      if (weights.containsKey(id)) _collected.add(id);
    }
  }
}
