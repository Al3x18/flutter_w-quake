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
    final earthquakesAsync = ref.watch(earthquakesFutureProvider);

    final earthquakeFeature = earthquakesAsync.maybeWhen(
      data: (list) => list.firstWhere(
        (eq) =>
            (eq.properties?.eventId?.toString() == earthquakeId) ||
            (eq.id == earthquakeId),
        orElse: () => throw Exception('Event not found'),
      ),
      orElse: () => throw Exception('Event not found'),
    );

    final earthquake = Earthquake(
      eventId: earthquakeFeature.properties?.eventId,
      eventIdString: earthquakeFeature.id,
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

    final allEarthquakes = earthquakesAsync.maybeWhen(
      data: (list) => list
          .map(
            (f) => Earthquake(
              eventId: f.properties?.eventId,
              eventIdString: f.id,
              originId: f.properties?.originId,
              time: f.properties?.time,
              author: f.properties?.author,
              magType: f.properties?.magType,
              mag: f.properties?.mag,
              magAuthor: f.properties?.magAuthor,
              type: f.properties?.type,
              place: f.properties?.place,
              version: f.properties?.version,
              geojsonCreationTime: f.properties?.geojsonCreationTime,
              geometry: f.geometry,
            ),
          )
          .toList(),
      orElse: () => <Earthquake>[],
    );

    final viewModel = ref.watch(earthquakeDetailViewModelProvider(earthquake));
    final locationState = ref.watch(locationViewModelProvider);
    final locationEnabled = ref.watch(locationEnabledSettingProvider);
    final mapViewModel = ref.watch(mapViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    void centerOnUserLocation() async {
      if (locationEnabled &&
          locationState.hasPermission &&
          locationState.currentPosition != null) {
        await mapViewModel.centerOnUserLocation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.locationPermissionRequiredMessage,
              style: TextStyle(color: Colors.black),
            ),
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
                        onPressed: centerOnUserLocation,
                        icon: Icon(
                          Icons.my_location,
                          color:
                              (locationEnabled && locationState.hasPermission)
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
              viewModel: viewModel,
            ),
          ),
        ],
      ),
    );
  }
}
