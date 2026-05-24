import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Lightweight location service for the stalker mechanic.
/// Gets the player's real city/district name to use in creepy messages.
/// Fails silently if permissions denied — falls back to generic text.
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  String? _cachedCity;
  String? _cachedDistrict;
  bool _attempted = false;

  String get city => _cachedCity ?? 'Twoim mieście';
  String get district => _cachedDistrict ?? 'Twojej okolicy';
  bool get hasRealLocation => _cachedCity != null;

  /// Attempt to get location. Call once early in the game.
  /// Silent fail — never blocks gameplay.
  Future<void> tryGetLocation() async {
    if (_attempted) return;
    _attempted = true;

    try {
      // Check if location services are enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      // Check permissions.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      // Get position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      // Reverse geocode to get city name.
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _cachedCity = place.locality ?? place.administrativeArea;
        _cachedDistrict = place.subLocality ?? place.street ?? place.locality;
      }
    } catch (_) {
      // Silent fail — game works without location.
    }
  }
}
