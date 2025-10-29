import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/earthquake.dart';
import '../providers/earthquake_providers.dart';
import '../providers/location_providers.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/earthquake_map_widget.dart';
import '../widgets/earthquake_detail_expansion_widget.dart';
import '../l10n/app_localizations.dart';

class EarthquakeDetailPage extends ConsumerWidget {
  final String earthquakeId;

  const EarthquakeDetailPage({super.key, required this.earthquakeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the earthquake in the current fetched list
    final earthquakesAsync = ref.watch(earthquakesFutureProvider);
    final eventId = int.parse(earthquakeId);
    final earthquakeFeature = earthquakesAsync.maybeWhen(
      data: (list) => list.firstWhere((eq) => eq.properties?.eventId == eventId, orElse: () => throw Exception('Event not found')),
      orElse: () => throw Exception('Event not found'),
    );
    final earthquake = Earthquake(
      eventId: earthquakeFeature.properties?.eventId,
      originId: earthquakeFeature.properties?.originId,
      time: earthquakeFeature.properties?.time,
      author: earthquakeFeature.properties?.author,
      magType: earthquakeFeature.properties?.magType,
      mag: earthquakeFeature.properties?.mag,
      magAuthor: earthquakeFeature.properties?.magAuthor,
      type: earthquakeFeature.properties?.type,
      place: earthquakeFeature.properties?.place,
      version: earthquakeFeature.properties?.version,
      geojsonCreationTime: earthquakeFeature.properties?.geojsonCreationTime,
      geometry: earthquakeFeature.geometry,
    );

    final viewModel = ref.watch(earthquakeDetailViewModelProvider(earthquake));
    final locationState = ref.watch(locationViewModelProvider);
    final locationEnabled = ref.watch(locationEnabledSettingProvider).maybeWhen(data: (v) => v, orElse: () => false);
    final mapViewModel = ref.watch(mapViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    void centerOnUserLocation() async {
      if (locationEnabled && locationState.hasPermission && locationState.currentPosition != null) {
        await mapViewModel.centerOnUserLocation();
      } else {
        // Show permission required message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationPermissionRequiredMessage, style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 50, left: 16, right: 16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen map
          Positioned.fill(
            child: EarthquakeMapWidget(earthquake: earthquake, height: MediaQuery.of(context).size.height),
          ),

          // Top buttons (back and center location)
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
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 24),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    // Center location button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: IconButton(
                        onPressed: centerOnUserLocation,
                        icon: Icon(Icons.my_location, color: (locationEnabled && locationState.hasPermission) ? Colors.orange : Colors.grey, size: 24),
                        padding: const EdgeInsets.all(12),
                        tooltip: l10n.centerOnMyLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom detail panel with floating effect
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: EarthquakeDetailExpansionWidget(earthquake: earthquake, viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}
