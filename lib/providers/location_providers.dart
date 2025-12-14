import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/settings_storage_service.dart';
import '../models/earthquake.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationEnabledSettingProvider = FutureProvider<bool>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadLocationEnabled();
});

final showUserLocationSettingProvider = FutureProvider<bool>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadShowUserLocation();
});

final userPositionProvider = StreamProvider<Position?>((ref) async* {
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

final locationPermissionProvider = FutureProvider<LocationPermission>((
  ref,
) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

final distanceCalculatorProvider = Provider<LocationService>((ref) {
  return ref.watch(locationServiceProvider);
});

final locationRadiusKmProvider = FutureProvider<int>((ref) async {
  final settings = SettingsStorageService();
  return await settings.loadLocationRadiusKm();
});

final earthquakeProximityProvider = Provider.family<bool, EarthquakeFeature>((
  ref,
  earthquake,
) {
  final locationEnabled = ref
      .watch(locationEnabledSettingProvider)
      .maybeWhen(data: (v) => v, orElse: () => false);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusAsync = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null || !radiusAsync.hasValue) {
    return false;
  }

  final radiusKm = radiusAsync.value!;
  final dMeters = distanceService.calculateDistanceToEarthquake(
    userPosition,
    earthquake.geometry?.coordinates?[1] ?? 0.0,
    earthquake.geometry?.coordinates?[0] ?? 0.0,
  );

  return dMeters <= (radiusKm * 1000);
});

final earthquakeDetailProximityProvider = Provider.family<bool, Earthquake>((
  ref,
  earthquake,
) {
  final locationEnabled = ref
      .watch(locationEnabledSettingProvider)
      .maybeWhen(data: (v) => v, orElse: () => false);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusAsync = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null || !radiusAsync.hasValue) {
    return false;
  }

  final radiusKm = radiusAsync.value!;
  final dMeters = distanceService.calculateDistanceToEarthquake(
    userPosition,
    earthquake.latitude,
    earthquake.longitude,
  );

  return dMeters <= (radiusKm * 1000);
});
