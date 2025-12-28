import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_extensions.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import 'settings_provider.dart';
import '../viewmodels/earthquake_viewmodel.dart';

final earthquakeApiServiceProvider = Provider<EarthquakeApiService>((ref) {
  return EarthquakeApiService();
});

final earthquakeViewModelProvider = Provider.autoDispose<EarthquakeViewModel>((ref) {
  final api = ref.read(earthquakeApiServiceProvider);
  return EarthquakeViewModel(apiService: api);
});

final effectiveFilterProvider = Provider<EarthquakeFilter>((ref) {
  final filter = ref.watch(filterProvider);
  final settingsAsync = ref.watch(settingsProvider);
  final defaultFilter = settingsAsync.value?.defaultFilter ?? const EarthquakeFilter();

  return filter.isFilterActive ? filter.currentFilter : defaultFilter;
});

final earthquakesFutureProvider = FutureProvider.autoDispose<List<EarthquakeFeature>>((ref) async {
  final vm = ref.watch(earthquakeViewModelProvider);
  final filter = ref.watch(effectiveFilterProvider);

  final settings = await ref.watch(settingsProvider.future);

  final list = await vm.fetchEarthquakesWithFilter(filter, source: settings.source);
  return list.sortedByTime();
});

class FilterState {
  final EarthquakeFilter currentFilter;
  final bool isFilterActive;

  const FilterState({this.currentFilter = const EarthquakeFilter(), this.isFilterActive = false});

  FilterState copyWith({EarthquakeFilter? currentFilter, bool? isFilterActive}) {
    return FilterState(currentFilter: currentFilter ?? this.currentFilter, isFilterActive: isFilterActive ?? this.isFilterActive);
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    ref.listen(settingsProvider, (previous, next) {
      next.whenData((settings) {
        if (settings.isInitialized) {
          _updateFilterFromDefaults(settings.defaultFilter);
        }
      });
    });

    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.value?.defaultFilter ?? const EarthquakeFilter();

    return _createInitialState(defaultFilter);
  }

  FilterState _createInitialState(EarthquakeFilter defaultFilter) {
    return FilterState(currentFilter: defaultFilter, isFilterActive: false);
  }

  void _updateFilterFromDefaults(EarthquakeFilter defaultFilter) {
    state = state.copyWith(currentFilter: defaultFilter, isFilterActive: false);
  }

  void updateFilter(EarthquakeFilter filter) {
    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.value?.defaultFilter ?? const EarthquakeFilter();

    final isActive =
        filter.area != defaultFilter.area ||
        filter.useCustomDateRange != defaultFilter.useCustomDateRange ||
        filter.minMagnitude != defaultFilter.minMagnitude ||
        filter.daysBack != defaultFilter.daysBack ||
        filter.customStartDate != defaultFilter.customStartDate ||
        filter.customEndDate != defaultFilter.customEndDate;

    state = state.copyWith(currentFilter: filter, isFilterActive: isActive);
  }

  void resetFilter() {
    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.value?.defaultFilter ?? const EarthquakeFilter();
    _updateFilterFromDefaults(defaultFilter);
  }

  void toggleFilter() {
    state = state.copyWith(isFilterActive: !state.isFilterActive);
  }

  void applyDefaultSettings() {
    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.value?.defaultFilter ?? const EarthquakeFilter();
    _updateFilterFromDefaults(defaultFilter);
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

final earthquakeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final asyncList = ref.watch(earthquakesFutureProvider);
  return asyncList.maybeWhen(
    data: (list) => list.calculateStats(),
    orElse: () => {'total': 0, 'maxMagnitude': 0.0, 'minMagnitude': 0.0, 'averageMagnitude': 0.0, 'strongestEarthquake': null, 'mostRecentEarthquake': null},
  );
});

class SelectedEarthquakeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectEarthquake(String earthquakeId) {
    state = earthquakeId;
  }

  void clear() {
    state = null;
  }
}

final selectedEarthquakeIdProvider = NotifierProvider<SelectedEarthquakeNotifier, String?>(SelectedEarthquakeNotifier.new);

final allEarthquakesProvider = Provider<List<Earthquake>>((ref) {
  final earthquakesAsync = ref.watch(earthquakesFutureProvider);
  return earthquakesAsync.maybeWhen(data: (list) => list.map(Earthquake.fromFeature).toList(), orElse: () => <Earthquake>[]);
});

final selectedEarthquakeProvider = Provider<Earthquake?>((ref) {
  final selectedId = ref.watch(selectedEarthquakeIdProvider);
  if (selectedId == null) return null;

  final earthquakes = ref.watch(allEarthquakesProvider);
  return earthquakes.cast<Earthquake?>().firstWhere((eq) => eq?.uniqueId == selectedId, orElse: () => null);
});
