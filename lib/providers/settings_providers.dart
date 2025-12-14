import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake_filter.dart';
import '../models/earthquake_source.dart';
import '../services/settings_storage_service.dart';
import '../viewmodels/settings_viewmodel.dart';

final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  return SettingsStorageService();
});

final settingsViewModelProvider = Provider<SettingsViewModel>((ref) {
  return SettingsViewModel();
});

class DefaultSettingsState {
  final EarthquakeFilter defaultFilter;
  final EarthquakeSource source;
  final bool isInitialized;

  const DefaultSettingsState({
    this.defaultFilter = const EarthquakeFilter(
      area: EarthquakeFilterArea.italy,
      minMagnitude: 2.0,
      daysBack: 1,
      useCustomDateRange: false,
    ),
    this.source = EarthquakeSource.ingv,
    this.isInitialized = false,
  });

  DefaultSettingsState copyWith({
    EarthquakeFilter? defaultFilter,
    EarthquakeSource? source,
    bool? isInitialized,
  }) {
    return DefaultSettingsState(
      defaultFilter: defaultFilter ?? this.defaultFilter,
      source: source ?? this.source,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class DefaultSettingsNotifier extends Notifier<DefaultSettingsState> {
  @override
  DefaultSettingsState build() {
    Future.microtask(() => _loadSavedSettings());

    const defaultFilter = EarthquakeFilter(
      area: EarthquakeFilterArea.italy,
      minMagnitude: 2.0,
      daysBack: 1,
      useCustomDateRange: false,
    );

    return DefaultSettingsState(
      defaultFilter: defaultFilter,
      isInitialized: true,
    );
  }

  Future<void> _loadSavedSettings() async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      final isInitialized = await storageService.isInitialized();
      final savedSource = await storageService.loadEarthquakeSource();

      if (isInitialized) {
        final savedFilter = await storageService.loadDefaultFilter();
        if (savedFilter != null) {
          state = state.copyWith(
            defaultFilter: savedFilter,
            source: savedSource,
            isInitialized: true,
          );
        } else {
          state = state.copyWith(source: savedSource, isInitialized: true);
        }
      } else {
        state = state.copyWith(source: savedSource, isInitialized: true);
      }
    } catch (e) {
      _setDefaultState();
    }
  }

  void _setDefaultState() {
    const defaultFilter = EarthquakeFilter(
      area: EarthquakeFilterArea.italy,
      minMagnitude: 2.0,
      daysBack: 1,
      useCustomDateRange: false,
    );

    state = DefaultSettingsState(
      defaultFilter: defaultFilter,
      source: EarthquakeSource.ingv,
      isInitialized: true,
    );
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

  Future<void> setEarthquakeSource(EarthquakeSource source) async {
    try {
      final storageService = ref.read(settingsStorageServiceProvider);
      await storageService.saveEarthquakeSource(source);
      state = state.copyWith(source: source);
    } catch (e) {
      state = state.copyWith(source: source);
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

final defaultSettingsProvider =
    NotifierProvider<DefaultSettingsNotifier, DefaultSettingsState>(() {
      return DefaultSettingsNotifier();
    });
