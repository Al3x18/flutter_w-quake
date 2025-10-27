import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// Provider for LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for current user position
final userPositionProvider = StreamProvider<Position?>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.locationStream;
});

/// Provider for location permission status
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

/// Provider for location service enabled status
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

/// Provider for distance calculation
final distanceCalculatorProvider = Provider<DistanceCalculator>((ref) {
  return DistanceCalculator();
});

class DistanceCalculator {
  /// Calculate distance between user position and earthquake
  double calculateDistanceToEarthquake(Position? userPosition, double earthquakeLat, double earthquakeLon) {
    if (userPosition == null) return 0.0;

    return Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, earthquakeLat, earthquakeLon);
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }
}
