import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences].
///
/// Kept intentionally tiny: every state notifier owns its own keys, this
/// class just centralises the prefs handle and the "wipe everything"
/// operation invoked by the Settings reset button.
///
/// Pattern of use:
/// 1. `await PersistenceService.init()` once in `main()`.
/// 2. Pass the singleton into each notifier's constructor.
/// 3. Notifiers read synchronously in their constructor and write
///    fire-and-forget on every mutation.
class PersistenceService {
  PersistenceService._(this._prefs);

  static PersistenceService? _instance;
  static PersistenceService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'PersistenceService.init() must be awaited before use.',
      );
    }
    return i;
  }

  final SharedPreferences _prefs;

  static Future<PersistenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final svc = PersistenceService._(prefs);
    _instance = svc;
    return svc;
  }

  // ---------- Primitive accessors ----------

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? const [];

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  /// Wipe every key the game owns. Used by the Settings reset button.
  Future<void> clearAll() => _prefs.clear();
}
