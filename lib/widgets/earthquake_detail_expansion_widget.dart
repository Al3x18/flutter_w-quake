import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../viewmodels/earthquake_detail_viewmodel.dart';
import '../l10n/app_localizations.dart';
import '../providers/location_providers.dart';

class EarthquakeDetailExpansionWidget extends ConsumerStatefulWidget {
  final Earthquake earthquake;
  final EarthquakeDetailViewModel viewModel;

  const EarthquakeDetailExpansionWidget({super.key, required this.earthquake, required this.viewModel});

  @override
  ConsumerState<EarthquakeDetailExpansionWidget> createState() => _EarthquakeDetailExpansionWidgetState();
}

class _EarthquakeDetailExpansionWidgetState extends ConsumerState<EarthquakeDetailExpansionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final earthquake = widget.earthquake;
    final viewModel = widget.viewModel;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          // Compute within-radius once for this build
          final userPosition = ref.watch(userPositionProvider).value;
          final radiusAsync = ref.watch(locationRadiusKmProvider);
          bool withinRadius = false;
          radiusAsync.whenData((radiusKm) {
            if (userPosition != null) {
              final distanceService = ref.watch(distanceCalculatorProvider);
              final dMeters = distanceService.calculateDistanceToEarthquake(userPosition, earthquake.latitude, earthquake.longitude);
              withinRadius = dMeters <= radiusKm * 1000;
            }
          });

          return GestureDetector(
            onTap: _toggleExpansion,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header always visible
                      Row(
                        children: [
                          Icon(Icons.waves, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.extractMainLocation(earthquake.place ?? l10n.unknownLocation),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: '${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}'.isEmpty ? TextAlign.center : TextAlign.start,
                                ),
                                if ('${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}'.isNotEmpty)
                                  Text('${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Time and magnitude on same row
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Time and magnitude on same row
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    viewModel.formatTime(earthquake.time),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                                    style: TextStyle(color: viewModel.getMagnitudeColor(earthquake.mag ?? 0.0), fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 2),
                                  Text('(${earthquake.magType ?? 'N/A'})', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[400], size: 20),
                        ],
                      ),
                      // Expandable content
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit expansion to 60% of screen height
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 16),

                                // Magnitude and depth section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.waves, color: viewModel.getMagnitudeColor(earthquake.mag ?? 0.0), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.magnitude,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          if (withinRadius) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.green, width: 0.8),
                                              ),
                                              child: Text(
                                                l10n.nearYou,
                                                style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '${earthquake.mag?.toStringAsFixed(1) ?? 'N/A'} ${earthquake.magType ?? ''}',
                                            style: TextStyle(color: viewModel.getMagnitudeColor(earthquake.mag ?? 0.0), fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(viewModel.getMagnitudeUncertainty(), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                            child: Text(
                                              earthquake.agency,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.height, color: Colors.blue, size: 16),
                                          const SizedBox(width: 8),
                                          Text('${l10n.depth}: ${viewModel.earthquake.formattedDepth} ${viewModel.getDepthUncertainty()}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                          const Spacer(),
                                          Text(viewModel.getDepthDescription(earthquake.depth, l10n), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Technical details section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.technicalDetails,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScalableDetailRow(l10n.eventId, earthquake.eventId?.toString() ?? 'N/A'),
                                      _buildScalableDetailRow(l10n.originId, earthquake.originId?.toString() ?? 'N/A'),
                                      _buildScalableDetailRow(l10n.author, earthquake.author ?? 'N/A'),
                                      _buildScalableDetailRow(l10n.type, earthquake.type ?? 'N/A'),
                                      _buildScalableDetailRow(l10n.version, earthquake.version?.toString() ?? 'N/A'),
                                      _buildScalableDetailRow(l10n.reviewStatus, earthquake.reviewStatus),
                                      _buildScalableDetailRow(l10n.stations, viewModel.getStationCount()),
                                      _buildScalableDetailRow(l10n.phases, viewModel.getPhaseCount()),
                                      // Distance from user (if location is enabled)
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final userPosition = ref.watch(userPositionProvider).value;
                                          if (userPosition != null) {
                                            final distanceCalculator = ref.watch(distanceCalculatorProvider);
                                            final distance = distanceCalculator.calculateDistanceToEarthquake(userPosition, earthquake.latitude, earthquake.longitude);
                                            return _buildScalableDetailRow(l10n.distanceFromYou, distanceCalculator.formatDistance(distance));
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Coordinates section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.red, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.coordinates,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScalableDetailRow(l10n.decimalDegrees, viewModel.formatCoordinates()),
                                      _buildScalableDetailRow(l10n.dmsFormat, viewModel.formatCoordinatesDMS()),
                                      _buildScalableDetailRow(l10n.preciseDecimal, viewModel.formatCoordinatesDecimal()),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Magnitude description
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.description, color: Colors.green, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.description,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.earthquakeDescription(
                                          earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                                          earthquake.magType ?? '',
                                          viewModel.getMagnitudeDescription(earthquake.mag ?? 0.0, l10n),
                                        ),
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${l10n.depth}: ${viewModel.getDepthDescription(earthquake.depth, l10n)} (${earthquake.depth.toStringAsFixed(1)} km)',
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${l10n.intensityLevel}: ${viewModel.getIntensityLevel(l10n)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScalableDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
