import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import 'settings_providers.dart';
import '../viewmodels/earthquake_viewmodel.dart';
import '../viewmodels/earthquake_detail_viewmodel.dart';
// Local state type used by FilterNotifier

// =============================================================================
// EARTHQUAKE DOMAIN - SERVICE PROVIDERS
// These providers expose the low-level services required by the earthquake
// feature (e.g., HTTP client for the INGV API).
// =============================================================================

final earthquakeApiServiceProvider = Provider<EarthquakeApiService>((ref) {
  return EarthquakeApiService();
});

// =============================================================================
// EARTHQUAKE DOMAIN - VIEWMODEL PROVIDERS
// ViewModels centralize domain/business logic. Widgets should depend on
// ViewModels instead of directly calling services.
// =============================================================================

// Auto-disposed to free resources when the consuming widget is removed.
final earthquakeViewModelProvider = Provider.autoDispose<EarthquakeViewModel>((ref) {
  final api = ref.read(earthquakeApiServiceProvider);
  return EarthquakeViewModel(apiService: api);
});

// Creates a detail ViewModel bound to a specific earthquake instance.
final earthquakeDetailViewModelProvider = Provider.family<EarthquakeDetailViewModel, Earthquake>((ref, earthquake) {
  return EarthquakeDetailViewModel(earthquake: earthquake);
});

// =============================================================================
// EARTHQUAKE DOMAIN - REACTIVE FILTER AND FETCH (FutureProvider-based)
// =============================================================================

// Effective filter combining defaults and active filter
final effectiveFilterProvider = Provider<EarthquakeFilter>((ref) {
  final filter = ref.watch(filterProvider);
  final defaults = ref.watch(defaultSettingsProvider);
  return filter.isFilterActive ? filter.currentFilter : defaults.defaultFilter;
});

// Reactive fetch of earthquakes when effective filter changes
final earthquakesFutureProvider = FutureProvider.autoDispose<List<EarthquakeFeature>>((ref) async {
  final vm = ref.watch(earthquakeViewModelProvider);
  final filter = ref.watch(effectiveFilterProvider);
  final list = await vm.fetchEarthquakesWithFilter(filter);
  return vm.sortEarthquakesByTime(list);
});

// DefaultSettingsState, LanguageState, InformationState moved to dedicated provider files

// =============================================================================
// EARTHQUAKE DOMAIN - STATE CLASSES (local)
// FilterState represents the current UI-selected filter. The actual fetch is
// handled reactively via earthquakesFutureProvider.
// =============================================================================

class FilterState {
  final EarthquakeFilter currentFilter;
  final bool isFilterActive;

  const FilterState({this.currentFilter = const EarthquakeFilter(), this.isFilterActive = false});

  FilterState copyWith({EarthquakeFilter? currentFilter, bool? isFilterActive}) {
    return FilterState(currentFilter: currentFilter ?? this.currentFilter, isFilterActive: isFilterActive ?? this.isFilterActive);
  }
}

// No Notifier for the earthquake list needed anymore; use earthquakesFutureProvider

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    // Keep filter in sync with persisted defaults
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

  // Update the current filter and mark it active only when it differs
  // from the default settings
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

  // Restore filter to default settings
  void resetFilter() {
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }

  // Enable/disable applying the custom filter
  void toggleFilter() {
    state = state.copyWith(isFilterActive: !state.isFilterActive);
  }

  // Force re-applying saved defaults
  void applyDefaultSettings() {
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }
}

// Notifiers for Language and Information are defined in their dedicated files

// =============================================================================
// EARTHQUAKE DOMAIN - MAIN PROVIDERS
// Expose filter state and computed derivations.
// =============================================================================

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

// defaultSettingsProvider, languageProvider, informationProvider are defined in their files

// Computed providers
// Stats computed from the reactive FutureProvider data
final earthquakeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final asyncList = ref.watch(earthquakesFutureProvider);
  final viewModel = ref.watch(earthquakeViewModelProvider);
  return asyncList.maybeWhen(
    data: (list) => viewModel.calculateEarthquakeStats(list),
    orElse: () => {'total': 0, 'maxMagnitude': 0.0, 'minMagnitude': 0.0, 'averageMagnitude': 0.0, 'strongestEarthquake': null, 'mostRecentEarthquake': null},
  );
});
