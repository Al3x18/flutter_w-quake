import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../viewmodels/location_viewmodel.dart';

class MapViewModel extends Notifier<MapState> {
  @override
  MapState build() {
    return MapState.initial();
  }

  /// Initialize map with earthquake data
  void initializeWithEarthquake(Earthquake earthquake) {
    centerOnEarthquake(earthquake);
  }

  /// Center map on earthquake location
  void centerOnEarthquake(Earthquake earthquake) {
    state = state.copyWith(center: LatLng(earthquake.latitude, earthquake.longitude), zoom: 8.0);
  }

  /// Center map on user location
  Future<void> centerOnUserLocation() async {
    final locationState = ref.read(locationViewModelProvider);

    if (locationState.hasPermission && locationState.currentPosition != null) {
      final position = locationState.currentPosition!;
      state = state.copyWith(
        center: LatLng(position.latitude, position.longitude),
        zoom: 12.0, // Closer zoom for user location
      );
    }
  }

  /// Center map to show both earthquake and user location
  Future<void> centerOnBothLocations(Earthquake earthquake) async {
    final locationState = ref.read(locationViewModelProvider);

    if (locationState.hasPermission && locationState.currentPosition != null) {
      final userPosition = locationState.currentPosition!;
      final earthquakeLatLng = LatLng(earthquake.latitude, earthquake.longitude);
      final userLatLng = LatLng(userPosition.latitude, userPosition.longitude);

      // Calculate bounds to include both points
      final minLat = earthquakeLatLng.latitude < userLatLng.latitude ? earthquakeLatLng.latitude : userLatLng.latitude;
      final maxLat = earthquakeLatLng.latitude > userLatLng.latitude ? earthquakeLatLng.latitude : userLatLng.latitude;
      final minLng = earthquakeLatLng.longitude < userLatLng.longitude ? earthquakeLatLng.longitude : userLatLng.longitude;
      final maxLng = earthquakeLatLng.longitude > userLatLng.longitude ? earthquakeLatLng.longitude : userLatLng.longitude;

      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

      // Calculate appropriate zoom level based on distance
      final distance = Geolocator.distanceBetween(earthquake.latitude, earthquake.longitude, userPosition.latitude, userPosition.longitude);

      double zoom;
      if (distance < 10000) {
        // Less than 10km
        zoom = 11.0;
      } else if (distance < 50000) {
        // Less than 50km
        zoom = 9.0;
      } else if (distance < 200000) {
        // Less than 200km
        zoom = 7.0;
      } else {
        zoom = 6.0;
      }

      state = state.copyWith(center: center, zoom: zoom);
    } else {
      // Fallback to earthquake only
      centerOnEarthquake(earthquake);
    }
  }

  /// Update map center and zoom
  void updateMapView(LatLng center, double zoom) {
    state = state.copyWith(center: center, zoom: zoom);
  }
}

class MapState {
  final LatLng center;
  final double zoom;

  const MapState({required this.center, required this.zoom});

  factory MapState.initial() {
    return const MapState(
      center: LatLng(41.9028, 12.4964), // Rome coordinates as default
      zoom: 6.0,
    );
  }

  MapState copyWith({LatLng? center, double? zoom}) {
    return MapState(center: center ?? this.center, zoom: zoom ?? this.zoom);
  }
}

/// Provider for MapViewModel
final mapViewModelProvider = NotifierProvider<MapViewModel, MapState>(() {
  return MapViewModel();
});
