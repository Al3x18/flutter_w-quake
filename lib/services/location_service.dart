import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  final StreamController<Position?> _locationController = StreamController<Position?>.broadcast();

  Stream<Position?> get locationStream => _locationController.stream;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermission.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermission.deniedForever;
    }

    return permission;
  }

  /// Get current position once
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.add(null);
        return null;
      }

      // Check and request permission
      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        _locationController.add(null);
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );

      _locationController.add(position);
      return position;
    } catch (e) {
      _locationController.add(null);
      return null;
    }
  }

  /// Start listening to position changes
  Future<void> startLocationUpdates() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.add(null);
        return;
      }

      // Check and request permission
      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        _locationController.add(null);
        return;
      }

      // Start listening to position changes
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen(
            (Position position) {
              _locationController.add(position);
            },
            onError: (error) {
              _locationController.add(null);
            },
          );
    } catch (e) {
      _locationController.add(null);
    }
  }

  /// Stop listening to position changes
  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Dispose resources
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}
