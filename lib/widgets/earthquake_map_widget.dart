import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../models/earthquake.dart';
import '../providers/location_providers.dart';
import '../services/settings_storage_service.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/earthquake_viewmodel.dart';

class EarthquakeMapWidget extends ConsumerStatefulWidget {
  final Earthquake earthquake;
  final List<Earthquake>? otherEarthquakes;
  final double height;

  const EarthquakeMapWidget({
    super.key,
    required this.earthquake,
    this.otherEarthquakes,
    this.height = 300,
  });

  @override
  ConsumerState<EarthquakeMapWidget> createState() =>
      _EarthquakeMapWidgetState();
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
      debugPrint('[EarthquakeMapWidget] Error loading settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapViewModelProvider);
    final earthquakeCenter = LatLng(
      widget.earthquake.latitude,
      widget.earthquake.longitude,
    );
    final earthquakeVm = EarthquakeViewModel();

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

    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      if (previous?.center != next.center || previous?.zoom != next.zoom) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'dev.alexdp.w_quake',
              maxZoom: 18,
            ),

            MarkerLayer(
              markers: [
                if (widget.otherEarthquakes != null)
                  ...widget.otherEarthquakes!
                      .where((e) => e.eventId != widget.earthquake.eventId)
                      .map((e) {
                        return Marker(
                          point: LatLng(e.latitude, e.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              context.pushReplacement(
                                '/earthquake/${e.uniqueId}',
                              );
                            },
                            child: Center(
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: earthquakeVm
                                      .getMagnitudeColor(e.mag ?? 0.0)
                                      .withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    e.mag?.toStringAsFixed(1) ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

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
                          color: earthquakeVm.getMagnitudeColor(
                            widget.earthquake.mag ?? 0.0,
                          ),
                          size: 16,
                        ),
                        Text(
                          widget.earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                          style: TextStyle(
                            color: earthquakeVm.getMagnitudeColor(
                              widget.earthquake.mag ?? 0.0,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showUserLocation && _userPosition != null)
                  Marker(
                    point: LatLng(
                      _userPosition!.latitude,
                      _userPosition!.longitude,
                    ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
