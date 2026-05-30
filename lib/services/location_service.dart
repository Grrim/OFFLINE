/// Simplified location service.
/// Removed real geolocation to avoid intrusive permissions and dependencies.
/// Always returns generic placeholders.
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  String get city => 'Twoim mieście';
  String get district => 'Twojej okolicy';
  bool get hasRealLocation => false;

  bool get isOptedIn => false;

  Future<void> setLocationOptIn(bool optIn) async {}

  Future<void> tryGetLocation() async {}
}
