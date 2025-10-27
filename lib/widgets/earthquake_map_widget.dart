import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../providers/location_providers.dart';
import '../services/settings_storage_service.dart';
import '../viewmodels/map_viewmodel.dart';

class EarthquakeMapWidget extends ConsumerStatefulWidget {
  final Earthquake earthquake;
  final double height;

  const EarthquakeMapWidget({super.key, required this.earthquake, this.height = 300});

  @override
  ConsumerState<EarthquakeMapWidget> createState() => _EarthquakeMapWidgetState();
}

class _EarthquakeMapWidgetState extends ConsumerState<EarthquakeMapWidget> {
  bool _showUserLocation = false;
  Position? _userPosition;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadSettings();

    // Initialize map with earthquake data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapViewModel = ref.read(mapViewModelProvider.notifier);
      mapViewModel.initializeWithEarthquake(widget.earthquake);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsService = SettingsStorageService();
      final showUserLocation = await settingsService.loadShowUserLocation();
      setState(() {
        _showUserLocation = showUserLocation;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapViewModelProvider);
    final earthquakeCenter = LatLng(widget.earthquake.latitude, widget.earthquake.longitude);

    // Watch user position if enabled
    if (_showUserLocation) {
      final userPosition = ref.watch(userPositionProvider).value;
      if (userPosition != null && _userPosition != userPosition) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _userPosition = userPosition;
          });
        });
      }
    }

    // Listen to map state changes and update map controller
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      if (previous?.center != next.center || previous?.zoom != next.zoom) {
        // Add a small delay to ensure map is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _mapController.move(next.center, next.zoom);
          }
        });
      }
    });

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: mapState.center,
            initialZoom: mapState.zoom,
            minZoom: 5.0,
            maxZoom: 15.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'dev.alexdp.w_quake', maxZoom: 18),
            // Earthquake marker
            MarkerLayer(
              markers: [
                Marker(
                  point: earthquakeCenter,
                  width: 45,
                  height: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getMagnitudeColor(widget.earthquake.mag ?? 0.0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.waves, color: Colors.white, size: 16),
                        Text(
                          widget.earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // User location marker (if enabled and position available)
                if (_showUserLocation && _userPosition != null)
                  Marker(
                    point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 6.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 4.0) return Colors.yellow;
    if (magnitude >= 3.0) return Colors.lightGreen;
    return Colors.green;
  }
}
