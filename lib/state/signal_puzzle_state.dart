import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Chapter 3 mini-puzzle — Signal handshake.
///
/// In Chapter 3 the prosecutor mentions a "secure channel password"
/// already established between N. and the witness team. The player must
/// reconstruct it from in-game clues:
/// - "koperta" — the codeword for the bribe envelopes (from N.'s notes
///   and recordings)
/// - "1422" — the timestamp of N.'s first dictaphone recording
///   (28.03.2026, 14:22) — already a clue for the second locked note
///
/// The expected password is `koperta1422`. The puzzle is case-insensitive
/// and trims whitespace. Three failed attempts in a row trigger a
/// soft-fail message but no permanent lockout — the player can keep
/// retrying.
///
/// On success: sets `puzzle.signal_decoded` flag (consumed by the
/// prosecutor dialogue), awards evidence, and fires `onDecoded`.
class SignalPuzzleState extends ChangeNotifier {
  SignalPuzzleState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kDecoded = 'game.signal.decoded';
  static const String _password = 'koperta1422';

  final PersistenceService? _persistence;

  bool _decoded = false;
  int _failedAttempts = 0;

  bool get isDecoded => _decoded;
  int get failedAttempts => _failedAttempts;

  /// Wired by the shell. Fires once on first successful decode.
  void Function()? onDecoded;

  /// Try the password. Returns true on match.
  bool tryDecode(String input) {
    if (_decoded) return true;
    final normalized = input.trim().toLowerCase();
    if (normalized != _password) {
      _failedAttempts += 1;
      notifyListeners();
      return false;
    }
    _decoded = true;
    _failedAttempts = 0;
    _persistence?.setBool(_kDecoded, true);
    notifyListeners();
    onDecoded?.call();
    return true;
  }

  void reset() {
    _decoded = false;
    _failedAttempts = 0;
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _decoded = p.getBool(_kDecoded);
  }
}
