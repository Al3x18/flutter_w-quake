import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'settings_provider.dart';
import '../models/earthquake.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationEnabledSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.locationEnabled ?? false;
});

final showUserLocationSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.showUserLocation ?? false;
});

final userPositionProvider = StreamProvider<Position?>((ref) async* {
  final settingsAsync = ref.watch(settingsProvider);
  final settings = settingsAsync.valueOrNull;

  final locationService = ref.watch(locationServiceProvider);

  // If settings are not loaded yet or disabled, stop updates and return null
  if (settings == null || !settings.locationEnabled || !settings.showUserLocation) {
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

final locationRadiusKmProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.locationRadiusKm ?? 100;
});

final earthquakeProximityProvider = Provider.family<bool, EarthquakeFeature>((
  ref,
  earthquake,
) {
  final locationEnabled = ref.watch(locationEnabledSettingProvider);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusKm = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null) {
    return false;
  }

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
  final locationEnabled = ref.watch(locationEnabledSettingProvider);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusKm = ref.watch(locationRadiusKmProvider);
  final distanceService = ref.watch(distanceCalculatorProvider);

  if (userPosition == null) {
    return false;
  }

  final dMeters = distanceService.calculateDistanceToEarthquake(
    userPosition,
    earthquake.latitude,
    earthquake.longitude,
  );

  return dMeters <= (radiusKm * 1000);
});
