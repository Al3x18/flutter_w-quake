import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  final StreamController<Position?> _locationController =
      StreamController<Position?>.broadcast();

  Stream<Position?> get locationStream => _locationController.stream;

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

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

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.add(null);
        return null;
      }

      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _locationController.add(null);
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _locationController.add(position);
      return position;
    } catch (e) {
      _locationController.add(null);
      return null;
    }
  }

  Future<void> startLocationUpdates() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationController.add(null);
        return;
      }

      LocationPermission permission = await requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _locationController.add(null);
        return;
      }

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
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

  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;

    _locationController.add(null);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  double calculateDistanceToEarthquake(
    Position? userPosition,
    double earthquakeLat,
    double earthquakeLon,
  ) {
    if (userPosition == null) return 0.0;
    return calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      earthquakeLat,
      earthquakeLon,
    );
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}
