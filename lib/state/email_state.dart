import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Fragments of a deleted message scattered across other apps.
/// Each fragment has a stable id used to mark it as recovered, plus a
/// piece of body text. Once all fragments are recovered, the
/// reconstructed message becomes visible in the inbox.
class EmailFragment {
  const EmailFragment({
    required this.id,
    required this.location,
    required this.body,
  });

  final String id;

  /// Human-readable location of the fragment ("Notatki → Zakupy",
  /// "Kalendarz → 16 maja"). Shown in the trash list.
  final String location;

  /// Text body of this fragment — concatenated in order to assemble
  /// the full reconstructed message.
  final String body;
}

/// Email app state.
///
/// Tracks read/unread state of inbox entries (decorative — no behaviour
/// change), and the recovery progress of N.'s deleted last message.
///
/// Recovery puzzle:
/// - 5 fragments are seeded under [allFragments].
/// - Each is "found" when the player taps a hidden hotspot in another app
///   (Notatki, Kalendarz, Mapy, Browser, Settings).
/// - When all 5 are recovered, [recoveredMessage] returns the reassembled
///   text, the message appears in the inbox with `id == 'recovered'`,
///   and the `puzzle.email_recovered` flag is raised by the shell.
class EmailState extends ChangeNotifier {
  EmailState({PersistenceService? persistence}) : _persistence = persistence {
    _load();
  }

  static const String _kRecovered = 'game.email.recoveredFragments';

  final PersistenceService? _persistence;
  final Set<String> _recovered = {};

  /// All 5 fragments. Order is the assembly order — concatenated as-is.
  static const List<EmailFragment> allFragments = [
    EmailFragment(
      id: 'frag_intro',
      location: 'Notatki → Zakupy',
      body:
          'Anita, jeśli to czytasz to znaczy że nie zdążyłam wysłać tej wiadomości w piątek. ',
    ),
    EmailFragment(
      id: 'frag_meeting',
      location: 'Kalendarz → Pt 16 maja, 14:00',
      body:
          'Spotykamy się w Kawiarni Relaks o 14:00. Mam wszystko: faktury, transkrypty, listę kopert. ',
    ),
    EmailFragment(
      id: 'frag_warning',
      location: 'Mapy → Las Kabacki — sektor C-2',
      body:
          'Jeśli mnie nie będzie - sprawdź sektor C-2. Tam ostatnio kopali w nocy. Coś tam zakopali. ',
    ),
    EmailFragment(
      id: 'frag_signal',
      location: 'Historia → Pobierz Signal',
      body:
          'Reszta materiałów - przez Signal. Hasło do mojego archiwum: imię kota + rok urodzenia, ',
    ),
    EmailFragment(
      id: 'frag_sign',
      location: 'Ustawienia → O grze (5x tap)',
      body:
          'wszystko się rozjaśni jak je odblokujesz. Trzymaj się. - N.',
    ),
  ];

  /// IDs of fragments currently recovered.
  Set<String> get recoveredFragmentIds => Set.unmodifiable(_recovered);

  int get recoveredCount => _recovered.length;
  int get totalFragments => allFragments.length;
  int get remainingCount => totalFragments - recoveredCount;

  /// True once every fragment has been found.
  bool get isFullyRecovered => recoveredCount == totalFragments;

  bool isRecovered(String id) => _recovered.contains(id);

  /// Returns the assembled message body if all fragments are present,
  /// otherwise null.
  String? get recoveredMessage {
    if (!isFullyRecovered) return null;
    final byId = {for (final f in allFragments) f.id: f};
    final buf = StringBuffer();
    for (final f in allFragments) {
      buf.write(byId[f.id]!.body);
    }
    return buf.toString();
  }

  /// Mark a fragment as recovered. Returns true on first recovery.
  /// Idempotent — repeats are no-op.
  bool recover(String fragmentId) {
    if (_recovered.contains(fragmentId)) return false;
    final exists = allFragments.any((f) => f.id == fragmentId);
    if (!exists) {
      assert(false, 'Unknown email fragment: $fragmentId');
      return false;
    }
    _recovered.add(fragmentId);
    _persist();
    notifyListeners();
    if (isFullyRecovered && !_fullyFired) {
      _fullyFired = true;
      onFullyRecovered?.call();
    }
    return true;
  }

  /// Wired by the shell. Fires once when all fragments are collected.
  void Function()? onFullyRecovered;
  bool _fullyFired = false;

  void reset() {
    if (_recovered.isEmpty) return;
    _recovered.clear();
    _fullyFired = false;
    notifyListeners();
  }

  void _persist() {
    _persistence?.setStringList(_kRecovered, _recovered.toList());
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    for (final id in p.getStringList(_kRecovered)) {
      // Drop fragment ids that no longer exist (catalog refactor).
      if (allFragments.any((f) => f.id == id)) _recovered.add(id);
    }
    if (isFullyRecovered) _fullyFired = true;
  }
}
