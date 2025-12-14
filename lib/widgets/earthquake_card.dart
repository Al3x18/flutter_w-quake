import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake.dart';
import '../viewmodels/earthquake_viewmodel.dart';

class EarthquakeCard extends StatelessWidget {
  final EarthquakeFeature earthquake;
  final EarthquakeViewModel? viewModel;
  final bool highlightNear;

  const EarthquakeCard({
    super.key,
    required this.earthquake,
    this.viewModel,
    this.highlightNear = false,
  });

  String _buildLocationTitle(String place) {
    if (viewModel == null) return place;

    final mainLocation = viewModel!.extractMainLocation(place);
    final province = viewModel!.extractProvince(place);

    if (province.isNotEmpty) {
      return '$mainLocation ($province)';
    } else {
      return mainLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final properties = earthquake.properties;
    final magnitude = properties?.mag ?? 0.0;
    final place = properties?.place ?? 'Luogo sconosciuto';

    if (viewModel == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        final eventId =
            earthquake.properties?.eventId?.toString() ?? earthquake.id ?? '0';
        context.push('/earthquake/$eventId');
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _buildLocationTitle(place).toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: viewModel!.formatDate(
                                          properties?.time,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[300],
                                              fontSize: 12,
                                            ),
                                      ),

                                      if (viewModel!
                                          .extractDistance(place)
                                          .trim()
                                          .isNotEmpty)
                                        TextSpan(
                                          text:
                                              ' • ${viewModel!.extractDistance(place)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[300],
                                                fontSize: 12,
                                              ),
                                        ),

                                      if ((properties?.type ?? '')
                                          .trim()
                                          .isNotEmpty)
                                        TextSpan(
                                          text:
                                              ' • (${(properties?.type ?? '').toLowerCase()})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[400],
                                                fontSize: 10,
                                              ),
                                        ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                viewModel!.formatTime(properties?.time),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[200],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '(${viewModel!.getTimeAgo(properties?.time, l10n)})',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                magnitude.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: viewModel!.getMagnitudeColor(
                                        magnitude,
                                      ),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '(${properties?.magType ?? 'N/A'})',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[400],
                                      fontSize: 8,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (highlightNear)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(width: 3, color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }
}
