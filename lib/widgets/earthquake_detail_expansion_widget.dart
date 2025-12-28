import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';
import '../models/earthquake_extensions.dart';
import '../l10n/app_localizations.dart';
import '../providers/location_providers.dart';

class EarthquakeDetailExpansionWidget extends ConsumerStatefulWidget {
  final Earthquake earthquake;

  const EarthquakeDetailExpansionWidget({super.key, required this.earthquake});

  @override
  ConsumerState<EarthquakeDetailExpansionWidget> createState() =>
      _EarthquakeDetailExpansionWidgetState();
}

class _EarthquakeDetailExpansionWidgetState
    extends ConsumerState<EarthquakeDetailExpansionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final withinRadius = ref.watch(
            earthquakeDetailProximityProvider(earthquake),
          );

          return GestureDetector(
            onTap: _toggleExpansion,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  earthquake.mainLocation.isNotEmpty
                                      ? earthquake.mainLocation
                                      : l10n.unknownLocation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign:
                                      '${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}'
                                          .isEmpty
                                      ? TextAlign.center
                                      : TextAlign.start,
                                ),
                                if ('${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}'
                                    .isNotEmpty)
                                  Text(
                                    '${earthquake.province}${earthquake.distance.isNotEmpty ? ', ${earthquake.distance}' : ''}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    earthquake.formattedTime,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    earthquake.mag?.toStringAsFixed(1) ?? 'N/A',
                                    style: TextStyle(
                                      color: earthquake.magnitudeColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '(${earthquake.magType ?? 'N/A'})',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),

                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.waves,
                                            color: earthquake.magnitudeColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.magnitude,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (withinRadius) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.green,
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                l10n.nearYou,
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                ),
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
                                            style: TextStyle(
                                              color: earthquake.magnitudeColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            earthquake.magnitudeUncertainty,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              earthquake.agency,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.height,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${l10n.depth}: ${earthquake.formattedDepth} ${earthquake.depthUncertainty}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            earthquake.getDepthDescription(
                                              l10n,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.technicalDetails,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScalableDetailRow(
                                        l10n.eventId,
                                        earthquake.eventId?.toString(),
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.originId,
                                        earthquake.originId?.toString(),
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.author,
                                        earthquake.author,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.type,
                                        earthquake.type,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.version,
                                        earthquake.version?.toString(),
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.reviewStatus,
                                        earthquake.reviewStatus == 'UNKNOWN'
                                            ? null
                                            : earthquake.reviewStatus,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.stations,
                                        earthquake.stationCount,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.phases,
                                        earthquake.phaseCount,
                                      ),

                                      Consumer(
                                        builder: (context, ref, child) {
                                          final userPosition = ref
                                              .watch(userPositionProvider)
                                              .value;
                                          if (userPosition != null) {
                                            final distance = Geolocator.distanceBetween(
                                              userPosition.latitude,
                                              userPosition.longitude,
                                              earthquake.geometry?.latitude ?? 0.0,
                                              earthquake.geometry?.longitude ?? 0.0,
                                            );
                                            final distanceKm = distance / 1000;
                                            final formattedDistance = distanceKm < 1
                                                ? '${distance.toStringAsFixed(0)} m'
                                                : '${distanceKm.toStringAsFixed(1)} km';
                                            return _buildScalableDetailRow(
                                              l10n.distanceFromYou,
                                              formattedDistance,
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.coordinates,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildScalableDetailRow(
                                        l10n.decimalDegrees,
                                        earthquake.formattedCoordinates,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.dmsFormat,
                                        earthquake.formattedCoordinatesDMS,
                                      ),
                                      _buildScalableDetailRow(
                                        l10n.preciseDecimal,
                                        earthquake.formattedCoordinatesDecimal,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.description,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.description,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.earthquakeDescription(
                                          earthquake.mag?.toStringAsFixed(1) ??
                                              'N/A',
                                          earthquake.magType ?? '',
                                          earthquake.getMagnitudeDescription(
                                            l10n,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${l10n.depth}: ${earthquake.getDepthDescription(l10n)} (${earthquake.depth.toStringAsFixed(1)} km)',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${l10n.intensityLevel}: ${earthquake.getIntensityLevel(l10n)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
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

  Widget _buildScalableDetailRow(String label, String? value) {
    if (value == null ||
        value.isEmpty ||
        value == 'N/A' ||
        value == 'UNKNOWN') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$label:',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 1,
              ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
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
