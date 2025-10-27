import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import '../services/settings_storage_service.dart';
import '../viewmodels/earthquake_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/earthquake_detail_viewmodel.dart';

// API Service provider
final earthquakeApiServiceProvider = Provider<EarthquakeApiService>((ref) {
  return EarthquakeApiService();
});

// ViewModel provider
final earthquakeViewModelProvider = Provider<EarthquakeViewModel>((ref) {
  return EarthquakeViewModel();
});

// Settings ViewModel provider
final settingsViewModelProvider = Provider<SettingsViewModel>((ref) {
  return SettingsViewModel();
});

// Settings Storage Service provider
final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  return SettingsStorageService();
});

// State for earthquake list
class EarthquakeListState {
  final List<EarthquakeFeature> earthquakes;
  final bool isLoading;
  final String? error;

  const EarthquakeListState({this.earthquakes = const [], this.isLoading = false, this.error});

  EarthquakeListState copyWith({List<EarthquakeFeature>? earthquakes, bool? isLoading, String? error}) {
    return EarthquakeListState(earthquakes: earthquakes ?? this.earthquakes, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

// Notifier for earthquake list
class EarthquakeListNotifier extends Notifier<EarthquakeListState> {
  @override
  EarthquakeListState build() {
    // Listen to default settings changes and load earthquakes when they're ready
    ref.listen(defaultSettingsProvider, (previous, next) {
      if (next.isInitialized && !state.isLoading) {
        loadEarthquakes();
      }
    });

    // Also listen to filter changes to ensure synchronization
    ref.listen(filterProvider, (previous, next) {
      if (previous == null && !state.isLoading) {
        // Initial load when filters are first set
        loadEarthquakes();
      }
    });

    return const EarthquakeListState();
  }

  Future<void> loadEarthquakes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final viewModel = ref.read(earthquakeViewModelProvider);
      final filterState = ref.read(filterProvider);
      final defaultSettings = ref.read(defaultSettingsProvider);

      debugPrint('[EarthquakeListNotifier] Loading earthquakes - Filter active: ${filterState.isFilterActive}'); // Debug logging
      debugPrint('[EarthquakeListNotifier] Current filter: ${filterState.currentFilter}'); // Debug logging

      List<EarthquakeFeature> earthquakes;

      // Use filter if active, otherwise use default settings
      if (filterState.isFilterActive) {
        debugPrint('[EarthquakeListNotifier] Using filtered earthquakes'); // Debug logging
        earthquakes = await viewModel.fetchEarthquakesWithFilter(filterState.currentFilter);
      } else {
        debugPrint('[EarthquakeListNotifier] Using default settings'); // Debug logging
        earthquakes = await viewModel.fetchEarthquakesWithFilter(defaultSettings.defaultFilter);
      }

      // Apply business logic: sort by time (most recent first)
      final sortedEarthquakes = viewModel.sortEarthquakesByTime(earthquakes);

      debugPrint('[EarthquakeListNotifier] Loaded ${sortedEarthquakes.length} earthquakes successfully'); // Debug logging
      state = state.copyWith(earthquakes: sortedEarthquakes, isLoading: false);
    } catch (e) {
      debugPrint('[EarthquakeListNotifier ERROR] Error in loadEarthquakes: $e'); // Debug logging
      // Extract user-friendly error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11); // Remove "Exception: " prefix
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> refreshEarthquakes() async {
    await loadEarthquakes();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for earthquake list notifier
final earthquakeListProvider = NotifierProvider<EarthquakeListNotifier, EarthquakeListState>(() {
  return EarthquakeListNotifier();
});

// Provider for filtered earthquakes (by magnitude)
final filteredEarthquakesProvider = Provider<List<EarthquakeFeature>>((ref) {
  final state = ref.watch(earthquakeListProvider);
  return state.earthquakes;
});

// Provider for earthquake statistics
final earthquakeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final earthquakes = ref.watch(filteredEarthquakesProvider);
  final viewModel = ref.watch(earthquakeViewModelProvider);

  // Use ViewModel business logic for calculating statistics
  return viewModel.calculateEarthquakeStats(earthquakes);
});

// Filter state
class FilterState {
  final EarthquakeFilter currentFilter;
  final bool isFilterActive;

  const FilterState({this.currentFilter = const EarthquakeFilter(), this.isFilterActive = false});

  FilterState copyWith({EarthquakeFilter? currentFilter, bool? isFilterActive}) {
    return FilterState(currentFilter: currentFilter ?? this.currentFilter, isFilterActive: isFilterActive ?? this.isFilterActive);
  }
}

// Filter notifier
class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    // Listen to default settings and update filters when they're ready
    ref.listen(defaultSettingsProvider, (previous, next) {
      if (next.isInitialized) {
        _updateFilterFromDefaults(next.defaultFilter);
      }
    });

    // Initialize with current default settings
    final defaultSettings = ref.read(defaultSettingsProvider);
    return _createInitialState(defaultSettings.defaultFilter);
  }

  FilterState _createInitialState(EarthquakeFilter defaultFilter) {
    // Default settings are never considered "active filters" - they're just defaults
    return FilterState(currentFilter: defaultFilter, isFilterActive: false);
  }

  void _updateFilterFromDefaults(EarthquakeFilter defaultFilter) {
    // Update filter to match default settings (but don't mark as active)
    state = state.copyWith(currentFilter: defaultFilter, isFilterActive: false);
  }

  void updateFilter(EarthquakeFilter filter) {
    // Filter is active only if it's different from current default settings
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
    // Reset to current default settings
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }

  void toggleFilter() {
    state = state.copyWith(isFilterActive: !state.isFilterActive);
  }

  void applyDefaultSettings() {
    // Explicitly apply current default settings (not considered active)
    final defaultSettings = ref.read(defaultSettingsProvider);
    _updateFilterFromDefaults(defaultSettings.defaultFilter);
  }
}

// Filter provider
final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

// Default settings state
class DefaultSettingsState {
  final EarthquakeFilter defaultFilter;
  final bool isInitialized;

  const DefaultSettingsState({this.defaultFilter = const EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1, useCustomDateRange: false), this.isInitialized = false});

  DefaultSettingsState copyWith({EarthquakeFilter? defaultFilter, bool? isInitialized}) {
    return DefaultSettingsState(defaultFilter: defaultFilter ?? this.defaultFilter, isInitialized: isInitialized ?? this.isInitialized);
  }
}

// Default settings notifier
class DefaultSettingsNotifier extends Notifier<DefaultSettingsState> {
  @override
  DefaultSettingsState build() {
    // Initialize with robust default values immediately, then load saved settings
    Future.microtask(() => _loadSavedSettings());

    // Use robust default filter for initial state
    const defaultFilter = EarthquakeFilter(
      area: EarthquakeFilterArea.italy, // Default to Italy
      minMagnitude: 2.0, // Minimum magnitude to avoid too many results
      daysBack: 1, // Last 24 hours
      useCustomDateRange: false,
    );

    return DefaultSettingsState(defaultFilter: defaultFilter, isInitialized: true);
  }

  /// Load saved settings from persistent storage
  Future<void> _loadSavedSettings() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      final isInitialized = await storageService.isInitialized();

      if (isInitialized) {
        final savedFilter = await storageService.loadDefaultFilter();
        if (savedFilter != null) {
          debugPrint('[DefaultSettings] Loaded saved settings');
          state = state.copyWith(defaultFilter: savedFilter, isInitialized: true);
        } else {
          debugPrint('[DefaultSettings] No saved settings found, using defaults');
          _setDefaultState();
        }
      } else {
        debugPrint('[DefaultSettings] Settings not initialized, using defaults');
        _setDefaultState();
      }
    } catch (e) {
      debugPrint('[DefaultSettings ERROR] Failed to load saved settings: $e');
      _setDefaultState();
    }
  }

  /// Set default state with robust default values
  void _setDefaultState() {
    // Create a robust default filter with safe values
    const defaultFilter = EarthquakeFilter(
      area: EarthquakeFilterArea.italy, // Default to Italy
      minMagnitude: 2.0, // Minimum magnitude to avoid too many results
      daysBack: 1, // Last 24 hours
      useCustomDateRange: false,
    );

    state = DefaultSettingsState(defaultFilter: defaultFilter, isInitialized: true);
    debugPrint('[DefaultSettings] Set robust default state: Italy, 2.0+, 1 day');
  }

  /// Set default filter and save to persistent storage
  Future<void> setDefaultFilter(EarthquakeFilter filter) async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.saveDefaultFilter(filter);
      state = state.copyWith(defaultFilter: filter, isInitialized: true);
      debugPrint('[DefaultSettings] Default filter set and saved');
    } catch (e) {
      debugPrint('[DefaultSettings ERROR] Failed to set default filter: $e');
      // Still update state even if storage fails
      state = state.copyWith(defaultFilter: filter, isInitialized: true);
    }
  }

  /// Reset to defaults and save to persistent storage
  Future<void> resetToDefaults() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.resetToDefaults();
      _setDefaultState();
      debugPrint('[DefaultSettings] Reset to defaults completed');
    } catch (e) {
      debugPrint('[DefaultSettings ERROR] Failed to reset to defaults: $e');
      // Still update state even if storage fails
      _setDefaultState();
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.clearSettings();
      _setDefaultState();
      debugPrint('[DefaultSettings] Settings cleared');
    } catch (e) {
      debugPrint('[DefaultSettings ERROR] Failed to clear settings: $e');
      // Still reset state even if storage fails
      _setDefaultState();
    }
  }
}

// Default settings provider
final defaultSettingsProvider = NotifierProvider<DefaultSettingsNotifier, DefaultSettingsState>(() {
  return DefaultSettingsNotifier();
});

// Earthquake Detail ViewModel provider
final earthquakeDetailViewModelProvider = Provider.family<EarthquakeDetailViewModel, Earthquake>((ref, earthquake) {
  return EarthquakeDetailViewModel(earthquake: earthquake);
});
