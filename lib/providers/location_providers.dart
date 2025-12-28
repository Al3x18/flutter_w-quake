import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'settings_provider.dart';
import '../models/earthquake.dart';

// --- Settings Providers (Shortcuts) ---

final locationEnabledSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.locationEnabled ?? false;
});

final showUserLocationSettingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.showUserLocation ?? false;
});

final locationRadiusKmProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.locationRadiusKm ?? 100;
});

// --- Core Location Providers ---

/// Stream of the user's current position.
/// Automatically handles settings (enabled/disabled) and permission checks.
final userPositionProvider = StreamProvider<Position?>((ref) async* {
  final settings = ref.watch(settingsProvider).valueOrNull;

  // 1. Check App Settings
  if (settings == null || !settings.locationEnabled || !settings.showUserLocation) {
    yield null;
    return;
  }

  // 2. Check System Service Status
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    yield null;
    return;
  }

  // 3. Check Permissions
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Note: We don't request permission here to avoid UI popups from a provider.
    // Permissions should be requested via the LocationController.
    yield null;
    return;
  }
  
  if (permission == LocationPermission.deniedForever) {
    yield null;
    return;
  }

  // 4. Get Position Stream
  try {
     // Emit last known position first for speed
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      yield lastKnown;
    }
    
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );

    yield* stream;
  } catch (e) {
    debugPrint('[LocationProvider] Error getting location stream: $e');
    yield null;
  }
});

/// Helper provider to check permission status reactively
final locationPermissionStatusProvider = FutureProvider<LocationPermission>((ref) async {
  // We depend on userPositionProvider to trigger refreshes, 
  // or we can just fetch it.
  return Geolocator.checkPermission();
});


// --- Location Controller (Actions) ---

class LocationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state needed really
  }

  Future<bool> requestPermission() async {
    state = const AsyncLoading();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncError('Location services are disabled', StackTrace.current);
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
            StackTrace.current);
        return false;
      }

      state = const AsyncData(null);
      // Invalidate providers to re-check permissions and restart streams
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

final locationControllerProvider = AsyncNotifierProvider<LocationController, void>(
  LocationController.new,
);

// --- Proximity Logic ---

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
    earthquake.latitude,
    earthquake.longitude,
  );

  return dMeters <= (radiusKm * 1000);
});
