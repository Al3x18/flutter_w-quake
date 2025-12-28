import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'settings_provider.dart';
import '../models/earthquake.dart';

final locationEnabledSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).value?.locationEnabled ?? false;
});

final showUserLocationSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).value?.showUserLocation ?? false;
});

final locationRadiusKmProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).value?.locationRadiusKm ?? 100;
});

final userPositionProvider = StreamProvider<Position?>((ref) async* {
  final settings = ref.watch(settingsProvider).value;

  if (settings == null ||
      !settings.locationEnabled ||
      !settings.showUserLocation) {
    yield null;
    return;
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield null;
    return;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    yield null;
    return;
  }

  if (permission == LocationPermission.deniedForever) {
    yield null;
    return;
  }

  try {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      yield lastKnown;
    }

    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    yield* stream;
  } catch (e) {
    debugPrint('[LocationProvider] Error getting location stream: $e');
    yield null;
  }
});

final locationPermissionStatusProvider = FutureProvider<LocationPermission>((
  ref,
) async {
  return Geolocator.checkPermission();
});

class LocationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
  }

  Future<bool> requestPermission() async {
    state = const AsyncLoading();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncError(
          'Location services are disabled',
          StackTrace.current,
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = AsyncError('Location permission denied', StackTrace.current);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncError(
          'Location permission permanently denied. Enable in settings.',
          StackTrace.current,
        );
        return false;
      }

      state = const AsyncData(null);
      ref.invalidate(userPositionProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }
}

final locationControllerProvider =
    AsyncNotifierProvider<LocationController, void>(LocationController.new);

final earthquakeProximityProvider = Provider.family<bool, EarthquakeFeature>((
  ref,
  earthquake,
) {
  final locationEnabled = ref.watch(locationEnabledSettingProvider);
  if (!locationEnabled) return false;

  final userPosition = ref.watch(userPositionProvider).value;
  final radiusKm = ref.watch(locationRadiusKmProvider);

  if (userPosition == null) return false;

  final dMeters = Geolocator.distanceBetween(
    userPosition.latitude,
    userPosition.longitude,
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

  if (userPosition == null) return false;

  final dMeters = Geolocator.distanceBetween(
    userPosition.latitude,
    userPosition.longitude,
    earthquake.geometry?.latitude ?? 0.0,
    earthquake.geometry?.longitude ?? 0.0,
  );

  return dMeters <= (radiusKm * 1000);
});
