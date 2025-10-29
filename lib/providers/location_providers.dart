import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/settings_storage_service.dart';
import '../models/earthquake.dart';

// Service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Settings flags providers
final locationEnabledSettingProvider = FutureProvider<bool>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadLocationEnabled();
});

final showUserLocationSettingProvider = FutureProvider<bool>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadShowUserLocation();
});

// Stream provider that ensures location updates start on first watch.
// Why async*?
// - We need to perform asynchronous bootstrap steps BEFORE exposing the stream
//   (get an initial position if possible, then start continuous updates).
// - Using async* allows us to:
//   1) await the bootstrap (getCurrentPosition + startLocationUpdates)
//   2) then yield* the real stream so all downstream listeners receive updates.
// Behavior on first subscribe (first ref.watch):
// - Tries to emit an initial position (if services+permission are OK)
// - Starts a continuous position stream
// - Forwards every update via yield* so UI reacts in real-time
// Notes:
// - If services are disabled or permissions denied, it yields null and keeps
//   listening for future availability without crashing the UI.
final userPositionProvider = StreamProvider<Position?>((ref) async* {
  // Respect user settings: if location is disabled or user location display is off,
  // do not start (or keep) location updates and emit null.
  final settings = SettingsStorageService();
  final isEnabled = await settings.loadLocationEnabled();
  final showUser = await settings.loadShowUserLocation();

  final locationService = ref.watch(locationServiceProvider);

  if (!isEnabled || !showUser) {
    locationService.stopLocationUpdates();
    yield null;
    return;
  }

  await locationService.getCurrentPosition();
  await locationService.startLocationUpdates();
  yield* locationService.locationStream;
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

// Location radius (km) provider - with default value
final locationRadiusKmProvider = FutureProvider<int>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadLocationRadiusKm();
});

// Combined provider that computes whether an EarthquakeFeature is within the
// user-defined radius around the current user position. It reacts to:
// - userPositionProvider stream updates
// - locationRadiusKmProvider (when radius is loaded/changed)
// Consumers in UI can just watch this boolean to show/hide indicators.
final earthquakeProximityProvider = Provider.family<bool, EarthquakeFeature>((ref, earthquake) {
  // If location is disabled in settings, proximity is always false
  final locationEnabled = ref.watch(locationEnabledSettingProvider).maybeWhen(data: (v) => v, orElse: () => false);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusAsync = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null || !radiusAsync.hasValue) {
    return false;
  }

  final radiusKm = radiusAsync.value!;
  final dMeters = distanceService.calculateDistanceToEarthquake(userPosition, earthquake.geometry?.coordinates?[1] ?? 0.0, earthquake.geometry?.coordinates?[0] ?? 0.0);

  return dMeters <= (radiusKm * 1000);
});

// Same as above, but for the Earthquake model used in details views.
final earthquakeDetailProximityProvider = Provider.family<bool, Earthquake>((ref, earthquake) {
  // If location is disabled in settings, proximity is always false
  final locationEnabled = ref.watch(locationEnabledSettingProvider).maybeWhen(data: (v) => v, orElse: () => false);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusAsync = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null || !radiusAsync.hasValue) {
    return false;
  }

  final radiusKm = radiusAsync.value!;
  final dMeters = distanceService.calculateDistanceToEarthquake(userPosition, earthquake.latitude, earthquake.longitude);

  return dMeters <= (radiusKm * 1000);
});
