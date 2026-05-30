import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences].
///
/// Centralises the prefs handle and provides a versioned schema with
/// migration support, plus a "wipe gameplay only" operation that
/// preserves user settings.
///
/// ## Key conventions
///
/// All keys are namespaced with one of two prefixes:
/// - `game.*` — gameplay progress (notes, files, chapter, ending,
///   threads, evidence, trust, ...). Wiped by [clearGameState].
/// - `settings.*` — durable user preferences (locale, audio mute,
///   reduced motion, telemetry opt-in, ...). NOT wiped on reset.
///
/// Legacy keys without prefixes from pre-versioning builds are migrated
/// on first launch by [_migrate].
///
/// ## Pattern of use
///
/// 1. `await PersistenceService.init()` once in `main()`.
/// 2. Pass the singleton into each notifier's constructor.
/// 3. Notifiers read synchronously in their constructor and write
///    fire-and-forget on every mutation.
class PersistenceService {
  PersistenceService._(this._prefs);

  /// The current schema version. Bumped when key layout changes; each
  /// bump must add a corresponding `if (saved < N)` branch in [_migrate].
  static const int currentSchemaVersion = 1;

  static const String _kSchemaVersion = '__schema_version__';

  /// Mapping from legacy unprefixed keys to current namespaced keys.
  /// Keys not listed here are preserved as-is (e.g. ones that already
  /// carry a prefix, or unrelated keys we shouldn't touch).
  static const Map<String, String> _legacyKeyMap = {
    'phone.isUnlocked': 'game.phone.isUnlocked',
    'photos.inspected': 'game.photos.inspected',
    'notes.unlockedIds': 'game.notes.unlockedIds',
    'notes.hookFired': 'game.notes.hookFired',
    'messages.progress.v1': 'game.messages.progress.v1',
    'files.opened': 'game.files.opened',
    'browser.visited': 'game.browser.visited',
    'chapter.current': 'game.chapter.current',
    'ending.activeId': 'game.ending.activeId',
  };

  /// Prefixes we recognise as gameplay state — wiped by reset.
  static const String gamePrefix = 'game.';

  /// Prefixes we recognise as durable user prefs — preserved on reset.
  static const String settingsPrefix = 'settings.';

  /// Prefixes we recognise as cross-run progression (achievements, NG+ stats) 
  /// — preserved on reset.
  static const String metaPrefix = 'meta.';

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
    await _migrate(prefs);
    final svc = PersistenceService._(prefs);
    _instance = svc;
    return svc;
  }

  /// Visible-for-testing variant that accepts an in-memory prefs handle.
  /// Tests pass `SharedPreferences.setMockInitialValues({...})` then
  /// `await PersistenceService.initForTesting()`.
  static Future<PersistenceService> initForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrate(prefs);
    final svc = PersistenceService._(prefs);
    _instance = svc;
    return svc;
  }

  // ---------- Migration ----------

  static Future<void> _migrate(SharedPreferences p) async {
    final saved = p.getInt(_kSchemaVersion) ?? 0;
    if (saved == currentSchemaVersion) return;

    if (saved < 1) {
      await _migrateToV1(p);
    }

    // Add future versions here:
    // if (saved < 2) await _migrateToV2(p);

    await p.setInt(_kSchemaVersion, currentSchemaVersion);
  }

  /// V1: rename legacy unprefixed keys to `game.*` / `settings.*`.
  static Future<void> _migrateToV1(SharedPreferences p) async {
    for (final entry in _legacyKeyMap.entries) {
      final oldKey = entry.key;
      final newKey = entry.value;
      if (!p.containsKey(oldKey)) continue;
      if (p.containsKey(newKey)) {
        // New key already populated — drop the legacy one.
        await p.remove(oldKey);
        continue;
      }
      // Use the type-agnostic getter and dispatch by runtime type.
      final dynamic value = p.get(oldKey);
      if (value is bool) {
        await p.setBool(newKey, value);
      } else if (value is int) {
        await p.setInt(newKey, value);
      } else if (value is double) {
        await p.setDouble(newKey, value);
      } else if (value is String) {
        await p.setString(newKey, value);
      } else if (value is List<String>) {
        await p.setStringList(newKey, value);
      } else if (value is List) {
        // Some platforms store List<dynamic> — coerce to List<String>.
        await p.setStringList(newKey, value.map((e) => e.toString()).toList());
      }
      await p.remove(oldKey);
    }
  }

  // ---------- Primitive accessors ----------

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  String getString(String key, {String defaultValue = ''}) =>
      _prefs.getString(key) ?? defaultValue;

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? const [];

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  bool containsKey(String key) => _prefs.containsKey(key);

  /// All persisted keys that begin with [prefix]. Used by state classes
  /// (e.g. `FlagsState`) that need to enumerate their own namespace at
  /// boot.
  Iterable<String> keysWithPrefix(String prefix) =>
      _prefs.getKeys().where((k) => k.startsWith(prefix));

  /// Wipes only gameplay state, preserves [settingsPrefix] keys and the
  /// schema version. Used by the Settings reset button.
  Future<void> clearGameState() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(gamePrefix));
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  /// Wipes EVERYTHING including settings and schema version.
  /// Used by tests and "factory reset" diagnostics.
  Future<void> clearAll() => _prefs.clear();
}
