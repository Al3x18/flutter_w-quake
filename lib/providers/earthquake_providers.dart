import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import 'settings_providers.dart';
import '../viewmodels/earthquake_viewmodel.dart';
import '../viewmodels/earthquake_detail_viewmodel.dart';

final earthquakeApiServiceProvider = Provider<EarthquakeApiService>((ref) {
  return EarthquakeApiService();
});

final earthquakeViewModelProvider = Provider.autoDispose<EarthquakeViewModel>((
  ref,
) {
  final api = ref.read(earthquakeApiServiceProvider);
  return EarthquakeViewModel(apiService: api);
});

final earthquakeDetailViewModelProvider =
    Provider.family<EarthquakeDetailViewModel, Earthquake>((ref, earthquake) {
      return EarthquakeDetailViewModel(earthquake: earthquake);
    });

final effectiveFilterProvider = Provider<EarthquakeFilter>((ref) {
  final filter = ref.watch(filterProvider);
  final defaults = ref.watch(defaultSettingsProvider);
  return filter.isFilterActive ? filter.currentFilter : defaults.defaultFilter;
});

final earthquakesFutureProvider =
    FutureProvider.autoDispose<List<EarthquakeFeature>>((ref) async {
      final vm = ref.watch(earthquakeViewModelProvider);
      final filter = ref.watch(effectiveFilterProvider);
      final settings = ref.watch(defaultSettingsProvider);

      final list = await vm.fetchEarthquakesWithFilter(
        filter,
        source: settings.source,
      );
      return vm.sortEarthquakesByTime(list);
    });

class FilterState {
  final EarthquakeFilter currentFilter;
  final bool isFilterActive;

  const FilterState({
    this.currentFilter = const EarthquakeFilter(),
    this.isFilterActive = false,
  });

  FilterState copyWith({
    EarthquakeFilter? currentFilter,
    bool? isFilterActive,
  }) {
    return FilterState(
      currentFilter: currentFilter ?? this.currentFilter,
      isFilterActive: isFilterActive ?? this.isFilterActive,
    );
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    ref.listen(defaultSettingsProvider, (previous, next) {
      if (next.isInitialized) {
        _updateFilterFromDefaults(next.defaultFilter);
      }
    });

    final defaultSettings = ref.read(defaultSettingsProvider);
    return _createInitialState(defaultSettings.defaultFilter);
  }

  FilterState _createInitialState(EarthquakeFilter defaultFilter) {
    return FilterState(currentFilter: defaultFilter, isFilterActive: false);
  }

  void _updateFilterFromDefaults(EarthquakeFilter defaultFilter) {
    state = state.copyWith(currentFilter: defaultFilter, isFilterActive: false);
  }

  void updateFilter(EarthquakeFilter filter) {
    final defaultSettings = ref.read(defaultSettingsProvider);
    final defaultFilter = defaultSettings.defaultFilter;

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
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }

  void toggleFilter() {
    state = state.copyWith(isFilterActive: !state.isFilterActive);
  }

  void applyDefaultSettings() {
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

final earthquakeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final asyncList = ref.watch(earthquakesFutureProvider);
  final viewModel = ref.watch(earthquakeViewModelProvider);
  return asyncList.maybeWhen(
    data: (list) => viewModel.calculateEarthquakeStats(list),
    orElse: () => {
      'total': 0,
      'maxMagnitude': 0.0,
      'minMagnitude': 0.0,
      'averageMagnitude': 0.0,
      'strongestEarthquake': null,
      'mostRecentEarthquake': null,
    },
  );
});
