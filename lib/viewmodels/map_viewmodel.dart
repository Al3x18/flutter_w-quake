import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../providers/location_providers.dart';

class MapViewModel extends Notifier<MapState> {
  @override
  MapState build() {
    return MapState.initial();
  }

  void initializeWithEarthquake(Earthquake earthquake) {
    centerOnEarthquake(earthquake);
  }

  void centerOnEarthquake(Earthquake earthquake) {
    state = state.copyWith(
      center: LatLng(earthquake.latitude, earthquake.longitude),
      zoom: 8.0,
    );
  }

  Future<void> centerOnUserLocation() async {
    final userPosition = ref.read(userPositionProvider).value;

    if (userPosition != null) {
      state = state.copyWith(
        center: LatLng(userPosition.latitude, userPosition.longitude),
        zoom: 12.0,
      );
    }
  }

  Future<void> centerOnBothLocations(Earthquake earthquake) async {
    final userPosition = ref.read(userPositionProvider).value;

    if (userPosition != null) {
      final earthquakeLatLng = LatLng(
        earthquake.latitude,
        earthquake.longitude,
      );
      final userLatLng = LatLng(userPosition.latitude, userPosition.longitude);

      final minLat = earthquakeLatLng.latitude < userLatLng.latitude
          ? earthquakeLatLng.latitude
          : userLatLng.latitude;
      final maxLat = earthquakeLatLng.latitude > userLatLng.latitude
          ? earthquakeLatLng.latitude
          : userLatLng.latitude;
      final minLng = earthquakeLatLng.longitude < userLatLng.longitude
          ? earthquakeLatLng.longitude
          : userLatLng.longitude;
      final maxLng = earthquakeLatLng.longitude > userLatLng.longitude
          ? earthquakeLatLng.longitude
          : userLatLng.longitude;

      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

      final distance = Geolocator.distanceBetween(
        earthquake.latitude,
        earthquake.longitude,
        userPosition.latitude,
        userPosition.longitude,
      );

      double zoom;
      if (distance < 10000) {
        zoom = 11.0;
      } else if (distance < 50000) {
        zoom = 9.0;
      } else if (distance < 200000) {
        zoom = 7.0;
      } else {
        zoom = 6.0;
      }

      state = state.copyWith(center: center, zoom: zoom);
    } else {
      centerOnEarthquake(earthquake);
    }
  }

  void updateMapView(LatLng center, double zoom) {
    state = state.copyWith(center: center, zoom: zoom);
  }
}

class MapState {
  final LatLng center;
  final double zoom;

  const MapState({required this.center, required this.zoom});

  factory MapState.initial() {
    return const MapState(center: LatLng(41.9028, 12.4964), zoom: 6.0);
  }

  MapState copyWith({LatLng? center, double? zoom}) {
    return MapState(center: center ?? this.center, zoom: zoom ?? this.zoom);
  }
}

final mapViewModelProvider = NotifierProvider<MapViewModel, MapState>(() {
  return MapViewModel();
});
