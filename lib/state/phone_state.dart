import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Global state for the simulated phone.
///
/// Phase 5: now persisted via [PersistenceService]. Only `isUnlocked` is
/// saved (failed attempts and transient error text are reset on reboot,
/// matching how a real device behaves).
class PhoneState extends ChangeNotifier {
  PhoneState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _correctPin = '1984';
  static const String _kIsUnlocked = 'phone.isUnlocked';

  final PersistenceService? _persistence;

  bool _isUnlocked = false;
  int _failedAttempts = 0;
  String? _lastError;

  bool get isUnlocked => _isUnlocked;
  int get failedAttempts => _failedAttempts;
  String? get lastError => _lastError;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _isUnlocked = p.getBool(_kIsUnlocked, defaultValue: false);
  }

  bool tryUnlock(String pin) {
    if (pin == _correctPin) {
      _isUnlocked = true;
      _lastError = null;
      _persistence?.setBool(_kIsUnlocked, true);
      notifyListeners();
      return true;
    }
    _failedAttempts += 1;
    _lastError = 'Nieprawidłowy kod';
    notifyListeners();
    return false;
  }

  void lock() {
    _isUnlocked = false;
    _lastError = null;
    _persistence?.setBool(_kIsUnlocked, false);
    notifyListeners();
  }

  void clearError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  /// Wipe in-memory state. The Settings reset button calls this after
  /// clearing prefs so the lock screen reappears immediately.
  void reset() {
    _isUnlocked = false;
    _failedAttempts = 0;
    _lastError = null;
    notifyListeners();
  }
}
