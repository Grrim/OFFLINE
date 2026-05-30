import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// One significant location with metadata + an exact timestamp used by
/// the route-reconstruction puzzle.
class MapPin {
  const MapPin({
    required this.id,
    required this.name,
    required this.address,
    required this.visitsLabel,
    required this.lastVisit,
    required this.routeTimestamp,
    this.isAlert = false,
  });

  final String id;
  final String name;
  final String address;
  final String visitsLabel; // e.g. "347 wizyt"
  final String lastVisit;   // human label, e.g. "17 maja, 18:30"
  final bool isAlert;

  /// Exact DateTime of the visit during the route to be reconstructed.
  /// Used for the correct-order check.
  final DateTime routeTimestamp;
}

/// Maps app state with the route-reconstruction puzzle.
///
/// 5 of the locations are part of N.'s last day. The player drags them
/// into chronological order. When the order matches, the puzzle is
/// solved, evidence is awarded and the `puzzle.route_reconstructed`
/// flag is set by the shell.
class MapsState extends ChangeNotifier {
  MapsState({PersistenceService? persistence}) : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kPlayerOrder = 'game.maps.playerOrder';
  static const String _kPuzzleSolved = 'game.maps.puzzleSolved';

  final PersistenceService? _persistence;
  final List<MapPin> _allPins = [];

  /// Stable shuffled order for the puzzle "To Add" list. 
  /// Generated once per session/reset to keep the puzzle non-obvious.
  final List<String> _shuffledIds = [];

  /// IDs of pins that participate in the route puzzle, in the order
  /// the player has currently arranged. Empty by default — player must
  /// pick them.
  final List<String> _playerOrder = [];

  bool _puzzleSolved = false;
  bool _solveFired = false;

  List<MapPin> get pins => List.unmodifiable(_allPins);

  /// Pins eligible for the route puzzle (have routeTimestamp on the
  /// last day). Other pins are decorative.
  static const Set<String> routePinIds = {
    'home',
    'work',
    'cafe_relaks',
    'parking_hipermarket',
    'las_kabacki',
  };

  List<MapPin> get routePins =>
      _allPins.where((p) => routePinIds.contains(p.id)).toList();

  /// Returns the route pins in a randomized order for the "remaining" list.
  List<MapPin> get shuffledRemainingPins {
    final remainingIds = _shuffledIds.where((id) => !_playerOrder.contains(id)).toList();
    final result = <MapPin>[];
    for (final id in remainingIds) {
      final pin = _allPins.firstWhere((p) => p.id == id);
      result.add(pin);
    }
    return result;
  }

  /// Order the player has assembled. May be partial.
  List<String> get playerOrder => List.unmodifiable(_playerOrder);

  bool get isPuzzleSolved => _puzzleSolved;

  /// Wired by the shell. Fires once, on transition from unsolved to solved.
  void Function()? onPuzzleSolved;

  /// Set/replace the player's ordering. Length may differ from
  /// [routePinIds.length]; partial orders are saved but never count as
  /// solved.
  void setPlayerOrder(List<String> order) {
    final filtered = order.where(routePinIds.contains).toList();
    if (_listEquals(_playerOrder, filtered)) return;
    _playerOrder
      ..clear()
      ..addAll(filtered);
    _persist();
    notifyListeners();
    _checkSolved();
  }

  /// Move pin within the player's ordering (drag-reorder helper).
  /// If the pin isn't in the order yet it's appended.
  void movePin(String id, int newIndex) {
    final list = List<String>.from(_playerOrder);
    list.remove(id);
    final clamped = newIndex.clamp(0, list.length);
    list.insert(clamped, id);
    setPlayerOrder(list);
  }

  /// Toggle inclusion of [id] in the order. Used by the "tap to add"
  /// affordance for pins not yet on the route list.
  void togglePin(String id) {
    if (!routePinIds.contains(id)) return;
    final list = List<String>.from(_playerOrder);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    setPlayerOrder(list);
  }

  /// Correct chronological order based on routeTimestamp.
  List<String> get correctOrder {
    final list = routePins.toList()
      ..sort((a, b) => a.routeTimestamp.compareTo(b.routeTimestamp));
    return list.map((p) => p.id).toList();
  }

  void _checkSolved() {
    final correct = correctOrder;
    final solved = _listEquals(_playerOrder, correct);
    if (solved == _puzzleSolved) return;
    _puzzleSolved = solved;
    _persistence?.setBool(_kPuzzleSolved, solved);
    if (solved && !_solveFired) {
      _solveFired = true;
      onPuzzleSolved?.call();
    }
  }

  void reset() {
    _playerOrder.clear();
    _puzzleSolved = false;
    _solveFired = false;
    _shuffledIds.clear();
    _shuffledIds.addAll(routePinIds.toList()..shuffle());
    notifyListeners();
  }

  void _persist() {
    _persistence?.setStringList(_kPlayerOrder, _playerOrder);
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _playerOrder.addAll(
      p.getStringList(_kPlayerOrder).where(routePinIds.contains),
    );
    _puzzleSolved = p.getBool(_kPuzzleSolved);
    if (_puzzleSolved) _solveFired = true;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ---------- Seed ----------
  //
  // Day-of timestamps: 17 maja 2026.
  // Correct route: home → work → cafe_relaks → parking_hipermarket → las_kabacki
  void _seed() {
    _shuffledIds.addAll(routePinIds.toList()..shuffle());
    _allPins.addAll([
      MapPin(
        id: 'home',
        name: 'Dom',
        address: 'ul. Puławska 142/14, Warszawa',
        visitsLabel: '347 wizyt',
        lastVisit: '17 maja, 09:08',
        routeTimestamp: DateTime(2026, 5, 17, 9, 8),
      ),
      MapPin(
        id: 'work',
        name: 'Praca',
        address: 'ul. Marszałkowska 89, Warszawa',
        visitsLabel: '124 wizyty',
        lastVisit: '17 maja, 10:22',
        routeTimestamp: DateTime(2026, 5, 17, 10, 22),
      ),
      MapPin(
        id: 'cafe_relaks',
        name: 'Cafe Relaks',
        address: 'ul. Mokotowska 17, Warszawa',
        visitsLabel: '23 wizyty',
        lastVisit: '17 maja, 14:00',
        routeTimestamp: DateTime(2026, 5, 17, 14, 0),
      ),
      MapPin(
        id: 'parking_hipermarket',
        name: 'Parking — hipermarket Mokotów',
        address: 'ul. Wołoska 12, Warszawa',
        visitsLabel: '4 wizyty',
        lastVisit: '17 maja, 21:14',
        routeTimestamp: DateTime(2026, 5, 17, 21, 14),
      ),
      MapPin(
        id: 'las_kabacki',
        name: 'Las Kabacki — sektor C-2',
        address: 'Las Kabacki, Warszawa-Ursynów',
        visitsLabel: '3 wizyty',
        lastVisit: '17 maja, 23:45',
        routeTimestamp: DateTime(2026, 5, 17, 23, 45),
        isAlert: true,
      ),
      // Decorative — not part of the puzzle.
      MapPin(
        id: 'plac_zbawiciela',
        name: 'Plac Zbawiciela',
        address: 'Plac Zbawiciela, Warszawa',
        visitsLabel: '8 wizyt',
        lastVisit: '14 maja, 17:22',
        routeTimestamp: DateTime(2026, 5, 14, 17, 22),
      ),
      MapPin(
        id: 'dworzec',
        name: 'Dworzec Warszawa Centralna',
        address: 'Al. Jerozolimskie 54, Warszawa',
        visitsLabel: '2 wizyty',
        lastVisit: '16 maja, 23:20',
        routeTimestamp: DateTime(2026, 5, 16, 23, 20),
      ),
    ]);
  }
}
