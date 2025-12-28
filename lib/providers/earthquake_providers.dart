import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import 'settings_provider.dart';
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
  final settingsAsync = ref.watch(settingsProvider);
  final defaultFilter = settingsAsync.valueOrNull?.defaultFilter ?? const EarthquakeFilter();
  
  return filter.isFilterActive ? filter.currentFilter : defaultFilter;
});

final earthquakesFutureProvider =
    FutureProvider.autoDispose<List<EarthquakeFeature>>((ref) async {
      final vm = ref.watch(earthquakeViewModelProvider);
      final filter = ref.watch(effectiveFilterProvider);
      
      // Ensure settings are loaded to get the correct source
      final settings = await ref.watch(settingsProvider.future);

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
    ref.listen(settingsProvider, (previous, next) {
      next.whenData((settings) {
        if (settings.isInitialized) {
          _updateFilterFromDefaults(settings.defaultFilter);
        }
      });
    });

    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.valueOrNull?.defaultFilter ?? const EarthquakeFilter();
    
    return _createInitialState(defaultFilter);
  }

  FilterState _createInitialState(EarthquakeFilter defaultFilter) {
    return FilterState(currentFilter: defaultFilter, isFilterActive: false);
  }

  void _updateFilterFromDefaults(EarthquakeFilter defaultFilter) {
    // Only update if we are not currently filtering or if we want to sync with defaults
    // The previous logic seemed to force update on initialization.
    // We'll keep the logic: if defaults change (and we are listening), we update the base state.
    // But if isFilterActive is true, maybe we should preserve it?
    // The previous code: state = state.copyWith(currentFilter: defaultFilter, isFilterActive: false);
    // This implies that loading defaults RESETS the current filter.
    state = state.copyWith(currentFilter: defaultFilter, isFilterActive: false);
  }

  void updateFilter(EarthquakeFilter filter) {
    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.valueOrNull?.defaultFilter ?? const EarthquakeFilter();

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
    final defaultFilter = settingsAsync.valueOrNull?.defaultFilter ?? const EarthquakeFilter();
    _updateFilterFromDefaults(defaultFilter);
  }

  void toggleFilter() {
    state = state.copyWith(isFilterActive: !state.isFilterActive);
  }

  void applyDefaultSettings() {
    final settingsAsync = ref.read(settingsProvider);
    final defaultFilter = settingsAsync.valueOrNull?.defaultFilter ?? const EarthquakeFilter();
    _updateFilterFromDefaults(defaultFilter);
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
