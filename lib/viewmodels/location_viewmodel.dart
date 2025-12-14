import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationViewModel extends Notifier<LocationState> {
  late LocationService _locationService;

  @override
  LocationState build() {
    _locationService = ref.watch(locationServiceProvider);

    _checkPermissionStatus();
    return LocationState.initial();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(hasPermission: false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      bool hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      state = state.copyWith(hasPermission: hasPermission);

      if (hasPermission) {
        Position? position = await _locationService.getCurrentPosition();
        if (position != null) {
          state = state.copyWith(currentPosition: position);
        }
      }
    } catch (e) {
      state = state.copyWith(hasPermission: false);
    }
  }

  Future<void> requestLocationPermission() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location services are disabled. Please enable them in settings.',
          hasPermission: false,
        );
        return;
      }

      LocationPermission permission = await _locationService
          .requestPermission();

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied.',
          hasPermission: false,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error:
              'Location permission permanently denied. Please enable it in app settings.',
          hasPermission: false,
        );
        return;
      }

      Position? position = await _locationService.getCurrentPosition();

      if (position != null) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: true,
          currentPosition: position,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to get current location.',
          hasPermission: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error getting location: ${e.toString()}',
        hasPermission: false,
      );
    }
  }

  Future<void> startLocationUpdates() async {
    if (state.hasPermission) {
      await _locationService.startLocationUpdates();
    }
  }

  void stopLocationUpdates() {
    _locationService.stopLocationUpdates();
  }

  double calculateDistanceToEarthquake(
    double earthquakeLat,
    double earthquakeLon,
  ) {
    if (state.currentPosition == null) return 0.0;

    return _locationService.calculateDistance(
      state.currentPosition!.latitude,
      state.currentPosition!.longitude,
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class LocationState {
  final bool isLoading;
  final bool hasPermission;
  final Position? currentPosition;
  final String? error;

  const LocationState({
    required this.isLoading,
    required this.hasPermission,
    this.currentPosition,
    this.error,
  });

  factory LocationState.initial() {
    return const LocationState(isLoading: false, hasPermission: false);
  }

  LocationState copyWith({
    bool? isLoading,
    bool? hasPermission,
    Position? currentPosition,
    String? error,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      currentPosition: currentPosition ?? this.currentPosition,
      error: error,
    );
  }

  bool get hasLocation => currentPosition != null;
  bool get hasError => error != null;
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationViewModelProvider =
    NotifierProvider<LocationViewModel, LocationState>(() {
      return LocationViewModel();
    });
