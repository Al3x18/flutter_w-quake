import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake_filter.dart';
import '../providers/earthquake_providers.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/earthquake_stats_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;
import '../widgets/filter_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Earthquakes will be loaded automatically when default settings are ready
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final earthquakeState = ref.watch(earthquakeListProvider);
    final stats = ref.watch(earthquakeStatsProvider);
    final viewModel = ref.watch(earthquakeViewModelProvider);
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            // App icon with seismic wave effect
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.waves, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            // App title with style
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('W', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('QUAKE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                // Live indicator
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.green, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        actions: [
          // Settings button
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
          // Filter button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => Stack(
                  children: [
                    // Blur background
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(color: Colors.black.withValues(alpha: 0.2)),
                      ),
                    ),
                    // Dialog
                    const Center(child: FilterDialog()),
                  ],
                ),
              );
            },
            icon: Icon(Icons.filter_list, color: filterState.isFilterActive ? Colors.orange : Colors.white),
            tooltip: l10n.filterEvents,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(earthquakeListProvider.notifier).refreshEarthquakes();
        },
        child: CustomScrollView(
          slivers: [
            // Header with stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          filterState.isFilterActive ? l10n.filteredEvents : l10n.recentEvents,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        if (filterState.isFilterActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              filterState.currentFilter.area.getTranslatedName(l10n),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ] else if (filterState.currentFilter.area != EarthquakeFilterArea.defaultArea) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              filterState.currentFilter.area.getTranslatedName(l10n),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(viewModel.getFilterDescription(filterState.currentFilter, l10n), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[200])),
                    const SizedBox(height: 16),
                    if (stats['total'] > 0) ...[EarthquakeStatsCard(stats: stats), const SizedBox(height: 8)],
                  ],
                ),
              ),
            ),
            // Earthquake list
            if (earthquakeState.isLoading)
              const SliverFillRemaining(child: LoadingWidget(message: 'Caricamento eventi...'))
            else if (earthquakeState.error != null)
              SliverFillRemaining(
                child: custom.ErrorWidget(
                  message: earthquakeState.error!,
                  onRetry: () {
                    ref.read(earthquakeListProvider.notifier).loadEarthquakes();
                  },
                ),
              )
            else if (earthquakeState.earthquakes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.waves, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(l10n.noEventsFound, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[200])),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final earthquake = earthquakeState.earthquakes[index];
                  final currentCategory = viewModel.getDateCategory(earthquake.properties?.time);

                  // Check if we need to show a separator
                  bool showSeparator = false;
                  String? separatorText;

                  if (index == 0) {
                    // Always show separator for first item
                    showSeparator = true;
                    if (currentCategory == 'today') {
                      separatorText = l10n.todaysEvents;
                    } else if (currentCategory == 'yesterday') {
                      separatorText = l10n.yesterdaysEvents;
                    } else {
                      separatorText = l10n.previousDaysEvents;
                    }
                  } else {
                    // Check if category changed from previous item
                    final previousEarthquake = earthquakeState.earthquakes[index - 1];
                    final previousCategory = viewModel.getDateCategory(previousEarthquake.properties?.time);

                    if (currentCategory != previousCategory) {
                      showSeparator = true;
                      if (currentCategory == 'yesterday') {
                        separatorText = l10n.yesterdaysEvents;
                      } else if (currentCategory == 'previous') {
                        separatorText = l10n.previousDaysEvents;
                      }
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSeparator && separatorText != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    currentCategory == 'today'
                                        ? Icons.today
                                        : currentCategory == 'yesterday'
                                        ? Icons.calendar_today
                                        : Icons.calendar_month,
                                    size: 12,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    separatorText.toUpperCase(),
                                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      EarthquakeCard(earthquake: earthquake, viewModel: viewModel),
                    ],
                  );
                }, childCount: earthquakeState.earthquakes.length),
              ),
          ],
        ),
      ),
    );
  }
}
