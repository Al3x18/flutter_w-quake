import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

// Service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Stream providers
final userPositionProvider = StreamProvider<Position?>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.locationStream;
});

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

// Distance calculator provider - using LocationService directly
final distanceCalculatorProvider = Provider<LocationService>((ref) {
  return ref.watch(locationServiceProvider);
});
