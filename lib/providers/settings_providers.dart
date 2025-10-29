import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake_filter.dart';
import '../services/settings_storage_service.dart';
import '../viewmodels/settings_viewmodel.dart';

// =============================================================================
// SETTINGS FEATURE - SERVICE AND VIEWMODEL PROVIDERS
// Provides access to persistent storage (defaults) and ViewModel utilities
// for validation and filter construction.
// =============================================================================
// Service provider
final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  return SettingsStorageService();
});

// Settings ViewModel provider (pure logic helpers for Settings screens)
final settingsViewModelProvider = Provider<SettingsViewModel>((ref) {
  return SettingsViewModel();
});

// =============================================================================
// SETTINGS FEATURE - STATE AND NOTIFIER
// Holds the persisted default filter and initialization status, backed by
// SettingsStorageService for load/save/reset operations.
// =============================================================================
// Default settings state
class DefaultSettingsState {
  final EarthquakeFilter defaultFilter;
  final bool isInitialized;

  const DefaultSettingsState({this.defaultFilter = const EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1, useCustomDateRange: false), this.isInitialized = false});

  DefaultSettingsState copyWith({EarthquakeFilter? defaultFilter, bool? isInitialized}) {
    return DefaultSettingsState(defaultFilter: defaultFilter ?? this.defaultFilter, isInitialized: isInitialized ?? this.isInitialized);
  }
}

// Notifier + provider
class DefaultSettingsNotifier extends Notifier<DefaultSettingsState> {
  @override
  DefaultSettingsState build() {
    Future.microtask(() => _loadSavedSettings());

    const defaultFilter = EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1, useCustomDateRange: false);

    return DefaultSettingsState(defaultFilter: defaultFilter, isInitialized: true);
  }

  Future<void> _loadSavedSettings() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      final isInitialized = await storageService.isInitialized();

      if (isInitialized) {
        final savedFilter = await storageService.loadDefaultFilter();
        if (savedFilter != null) {
          state = state.copyWith(defaultFilter: savedFilter, isInitialized: true);
        } else {
          _setDefaultState();
        }
      } else {
        _setDefaultState();
      }
    } catch (e) {
      _setDefaultState();
    }
  }

  void _setDefaultState() {
    const defaultFilter = EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1, useCustomDateRange: false);

    state = DefaultSettingsState(defaultFilter: defaultFilter, isInitialized: true);
  }

  Future<void> setDefaultFilter(EarthquakeFilter filter) async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.saveDefaultFilter(filter);
      state = state.copyWith(defaultFilter: filter, isInitialized: true);
    } catch (e) {
      state = state.copyWith(defaultFilter: filter, isInitialized: true);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.resetToDefaults();
      _setDefaultState();
    } catch (e) {
      _setDefaultState();
    }
  }

  Future<void> clearSettings() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.clearSettings();
      _setDefaultState();
    } catch (e) {
      _setDefaultState();
    }
  }
}

final defaultSettingsProvider = NotifierProvider<DefaultSettingsNotifier, DefaultSettingsState>(() {
  return DefaultSettingsNotifier();
});
