import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/earthquake_providers.dart';
import '../providers/location_providers.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/earthquake_map_widget.dart';
import '../widgets/earthquake_detail_expansion_widget.dart';
import '../l10n/app_localizations.dart';

class EarthquakeDetailPage extends ConsumerStatefulWidget {
  final String earthquakeId;

  const EarthquakeDetailPage({super.key, required this.earthquakeId});

  @override
  ConsumerState<EarthquakeDetailPage> createState() =>
      _EarthquakeDetailPageState();
}

class _EarthquakeDetailPageState extends ConsumerState<EarthquakeDetailPage> {
  late final SelectedEarthquakeNotifier _selectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedNotifier = ref.read(selectedEarthquakeIdProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedNotifier.selectEarthquake(widget.earthquakeId);
    });
  }

  @override
  void dispose() {
    Future.microtask(() => _selectedNotifier.clear());
    super.dispose();
  }

  void _centerOnUserLocation() async {
    final locationEnabled = ref.read(locationEnabledSettingProvider);
    final hasLocation = ref.read(userPositionProvider).value != null;
    final mapViewModel = ref.read(mapViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    if (locationEnabled && hasLocation) {
      await mapViewModel.centerOnUserLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locationPermissionRequiredMessage,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final earthquake = ref.watch(selectedEarthquakeProvider);
    final allEarthquakes = ref.watch(allEarthquakesProvider);
    final userPositionAsync = ref.watch(userPositionProvider);
    final locationEnabled = ref.watch(locationEnabledSettingProvider);
    final l10n = AppLocalizations.of(context)!;

    if (earthquake == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: EarthquakeMapWidget(
              earthquake: earthquake,
              otherEarthquakes: allEarthquakes,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.orange,
                          size: 24,
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _centerOnUserLocation,
                        icon: Icon(
                          Icons.my_location,
                          color: (locationEnabled &&
                                  userPositionAsync.value != null)
                              ? Colors.orange
                              : Colors.grey,
                          size: 24,
                        ),
                        padding: const EdgeInsets.all(12),
                        tooltip: l10n.centerOnMyLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: EarthquakeDetailExpansionWidget(
              earthquake: earthquake,
            ),
          ),
        ],
      ),
    );
  }
}
