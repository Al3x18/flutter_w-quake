import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake_extensions.dart';
import '../models/earthquake_filter.dart';
import '../providers/earthquake_providers.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/earthquake_stats_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;
import '../widgets/filter_dialog.dart';
import '../providers/location_providers.dart';
import '../providers/first_launch_provider.dart';
import '../widgets/location_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firstLaunchProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final earthquakesAsync = ref.watch(earthquakesFutureProvider);
    final stats = ref.watch(earthquakeStatsProvider);
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.waves, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),

            Row(
              children: [
                Text(
                  'W',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.orange.withValues(alpha: 0.3), offset: const Offset(0, 2), blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'QUAKE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.orange.withValues(alpha: 0.3), offset: const Offset(0, 2), blurRadius: 4)],
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                    letterSpacing: 1.5,
                    shadows: [Shadow(color: Colors.green.withValues(alpha: 0.4), offset: const Offset(0, 1), blurRadius: 3)],
                  ),
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
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),

          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(color: Colors.black.withValues(alpha: 0.2)),
                      ),
                    ),

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
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(earthquakesFutureProvider);
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: const LocationBanner()),
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
                    Text(filterState.currentFilter.getDescription(l10n), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[200])),
                    const SizedBox(height: 16),
                    if (stats['total'] > 0) ...[EarthquakeStatsCard(stats: stats), const SizedBox(height: 8)],
                  ],
                ),
              ),
            ),

            earthquakesAsync.when(
              loading: () => SliverFillRemaining(child: LoadingWidget(message: l10n.loadingEvents)),
              error: (err, st) => SliverFillRemaining(
                child: custom.ErrorWidget(message: err.toString().replaceFirst('Exception: ', ''), onRetry: () => ref.invalidate(earthquakesFutureProvider)),
              ),
              data: (earthquakeList) => earthquakeList.isEmpty
                  ? SliverFillRemaining(
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
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final earthquake = earthquakeList[index];
                        final withinRadius = ref.watch(earthquakeProximityProvider(earthquake));
                        final currentCategory = earthquake.getDateCategory();

                        bool showSeparator = false;
                        String? separatorText;

                        if (index == 0) {
                          showSeparator = true;
                          if (currentCategory == 'today') {
                            separatorText = l10n.todaysEvents;
                          } else if (currentCategory == 'yesterday') {
                            separatorText = l10n.yesterdaysEvents;
                          } else {
                            separatorText = l10n.previousDaysEvents;
                          }
                        } else {
                          final previousEarthquake = earthquakeList[index - 1];
                          final previousCategory = previousEarthquake.getDateCategory();

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
                                          style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            EarthquakeCard(earthquake: earthquake, highlightNear: withinRadius),
                          ],
                        );
                      }, childCount: earthquakeList.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
