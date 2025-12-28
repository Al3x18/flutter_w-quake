import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/earthquake.dart';
import '../models/earthquake_extensions.dart';
import '../providers/earthquake_providers.dart';
import '../providers/location_providers.dart';
import '../viewmodels/map_viewmodel.dart';

class EarthquakeMapWidget extends ConsumerStatefulWidget {
  final Earthquake earthquake;
  final List<Earthquake> otherEarthquakes;
  final double height;

  const EarthquakeMapWidget({
    super.key,
    required this.earthquake,
    required this.otherEarthquakes,
    required this.height,
  });

  @override
  ConsumerState<EarthquakeMapWidget> createState() =>
      _EarthquakeMapWidgetState();
}

class _EarthquakeMapWidgetState extends ConsumerState<EarthquakeMapWidget> {
  late MapController _mapController;
  bool _initialized = false;
  LatLng? _lastCenter;
  double? _lastZoom;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _centerOnEarthquake();
        _initialized = true;
      }
    });
  }

  void _centerOnEarthquake() {
    final lat = widget.earthquake.geometry?.latitude ?? 0.0;
    final lon = widget.earthquake.geometry?.longitude ?? 0.0;
    const zoom = 12.0;
    _mapController.move(LatLng(lat, lon), zoom);
    _lastCenter = LatLng(lat, lon);
    _lastZoom = zoom;
  }

  @override
  void didUpdateWidget(EarthquakeMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.earthquake.uniqueId != widget.earthquake.uniqueId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerOnEarthquake();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  bool _isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final showUserLocation = ref.watch(showUserLocationSettingProvider);
    final userPosition = ref.watch(userPositionProvider).value;
    
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      if (_lastCenter != next.center || _lastZoom != next.zoom) {
        _mapController.move(next.center, next.zoom);
        _lastCenter = next.center;
        _lastZoom = next.zoom;
      }
    });

    final earthquakeCenter = LatLng(
      widget.earthquake.geometry?.latitude ?? 0.0,
      widget.earthquake.geometry?.longitude ?? 0.0,
    );

    final markers = <Marker>[];

    for (final e in widget.otherEarthquakes) {
      if (e.uniqueId == widget.earthquake.uniqueId) continue;

      final lat = e.geometry?.latitude ?? 0.0;
      final lon = e.geometry?.longitude ?? 0.0;
      final bgColor = e.magnitudeColor.withValues(alpha: 0.8);
      final isLight = _isLightColor(e.magnitudeColor);
      final textColor = isLight ? Colors.black : Colors.white;
      final borderColor = isLight
          ? Colors.black.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.8);

      markers.add(
        Marker(
          point: LatLng(lat, lon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedEarthquakeIdProvider.notifier).selectEarthquake(e.uniqueId);
              _mapController.move(LatLng(lat, lon), 12.0);
              _lastCenter = LatLng(lat, lon);
              _lastZoom = 12.0;
            },
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    e.mag?.toStringAsFixed(1) ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    markers.add(
      Marker(
        point: earthquakeCenter,
        width: 45,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.waves,
                color: widget.earthquake.magnitudeColor,
                size: 16,
              ),
              Text(
                widget.earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                style: TextStyle(
                  color: widget.earthquake.magnitudeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (showUserLocation && userPosition != null) {
      markers.add(
        Marker(
          point: LatLng(userPosition.latitude, userPosition.longitude),
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: earthquakeCenter,
          initialZoom: 12.0,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              _lastCenter = position.center;
              _lastZoom = position.zoom;
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.w_quake',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
