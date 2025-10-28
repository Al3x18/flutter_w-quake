import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';
import '../services/settings_storage_service.dart';
import '../services/language_service.dart';
import '../services/information_service.dart';
import '../viewmodels/earthquake_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/earthquake_detail_viewmodel.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

final earthquakeApiServiceProvider = Provider<EarthquakeApiService>((ref) {
  return EarthquakeApiService();
});

final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  return SettingsStorageService();
});

final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

final informationServiceProvider = Provider<InformationService>((ref) {
  return InformationService();
});

// ============================================================================
// VIEWMODEL PROVIDERS
// ============================================================================

final earthquakeViewModelProvider = Provider<EarthquakeViewModel>((ref) {
  return EarthquakeViewModel();
});

final settingsViewModelProvider = Provider<SettingsViewModel>((ref) {
  return SettingsViewModel();
});

final earthquakeDetailViewModelProvider = Provider.family<EarthquakeDetailViewModel, Earthquake>((ref, earthquake) {
  return EarthquakeDetailViewModel(earthquake: earthquake);
});

// ============================================================================
// STATE CLASSES
// ============================================================================

class EarthquakeListState {
  final List<EarthquakeFeature> earthquakes;
  final bool isLoading;
  final String? error;

  const EarthquakeListState({this.earthquakes = const [], this.isLoading = false, this.error});

  EarthquakeListState copyWith({List<EarthquakeFeature>? earthquakes, bool? isLoading, String? error}) {
    return EarthquakeListState(earthquakes: earthquakes ?? this.earthquakes, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

class FilterState {
  final EarthquakeFilter currentFilter;
  final bool isFilterActive;

  const FilterState({this.currentFilter = const EarthquakeFilter(), this.isFilterActive = false});

  FilterState copyWith({EarthquakeFilter? currentFilter, bool? isFilterActive}) {
    return FilterState(currentFilter: currentFilter ?? this.currentFilter, isFilterActive: isFilterActive ?? this.isFilterActive);
  }
}

class DefaultSettingsState {
  final EarthquakeFilter defaultFilter;
  final bool isInitialized;

  const DefaultSettingsState({this.defaultFilter = const EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1, useCustomDateRange: false), this.isInitialized = false});

  DefaultSettingsState copyWith({EarthquakeFilter? defaultFilter, bool? isInitialized}) {
    return DefaultSettingsState(defaultFilter: defaultFilter ?? this.defaultFilter, isInitialized: isInitialized ?? this.isInitialized);
  }
}

class LanguageState {
  final String currentLanguage;
  final bool isInitialized;

  const LanguageState({this.currentLanguage = 'en', this.isInitialized = false});

  LanguageState copyWith({String? currentLanguage, bool? isInitialized}) {
    return LanguageState(currentLanguage: currentLanguage ?? this.currentLanguage, isInitialized: isInitialized ?? this.isInitialized);
  }
}

class InformationState {
  final String appVersion;
  final String versionOnly;
  final String buildNumber;
  final String packageName;
  final String appName;
  final String appDescription;
  final String developerName;
  final bool isLoading;
  final String? error;

  const InformationState({
    this.appVersion = 'Unknown',
    this.versionOnly = 'Unknown',
    this.buildNumber = 'Unknown',
    this.packageName = 'Unknown',
    this.appName = 'W-Quake',
    this.appDescription = 'Real-time earthquake monitoring app',
    this.developerName = 'W-Quake Team',
    this.isLoading = false,
    this.error,
  });

  InformationState copyWith({
    String? appVersion,
    String? versionOnly,
    String? buildNumber,
    String? packageName,
    String? appName,
    String? appDescription,
    String? developerName,
    bool? isLoading,
    String? error,
  }) {
    return InformationState(
      appVersion: appVersion ?? this.appVersion,
      versionOnly: versionOnly ?? this.versionOnly,
      buildNumber: buildNumber ?? this.buildNumber,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appDescription: appDescription ?? this.appDescription,
      developerName: developerName ?? this.developerName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ============================================================================
// NOTIFIERS
// ============================================================================

class EarthquakeListNotifier extends Notifier<EarthquakeListState> {
  @override
  EarthquakeListState build() {
    ref.listen(defaultSettingsProvider, (previous, next) {
      if (next.isInitialized && !state.isLoading) {
        loadEarthquakes();
      }
    });

    ref.listen(filterProvider, (previous, next) {
      if (previous == null && !state.isLoading) {
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

      List<EarthquakeFeature> earthquakes;

      if (filterState.isFilterActive) {
        earthquakes = await viewModel.fetchEarthquakesWithFilter(filterState.currentFilter);
      } else {
        earthquakes = await viewModel.fetchEarthquakesWithFilter(defaultSettings.defaultFilter);
      }

      final sortedEarthquakes = viewModel.sortEarthquakesByTime(earthquakes);
      state = state.copyWith(earthquakes: sortedEarthquakes, isLoading: false);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
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

class LanguageNotifier extends Notifier<LanguageState> {
  static const Map<String, String> _languageNames = {'en': 'English', 'it': 'Italiano'};

  LanguageService get _service => ref.read(languageServiceProvider);

  @override
  LanguageState build() {
    _loadSavedLanguage();
    return const LanguageState();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final currentLanguage = await _service.loadLanguage();
      state = state.copyWith(currentLanguage: currentLanguage, isInitialized: true);
    } catch (e) {
      state = state.copyWith(currentLanguage: _service.getDefaultLanguage(), isInitialized: true);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!_isValidLanguageCode(languageCode)) {
      return;
    }

    try {
      await _service.saveLanguage(languageCode);
      state = state.copyWith(currentLanguage: languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetToDefault() async {
    try {
      await _service.clearLanguage();
      final defaultLanguage = _service.getDefaultLanguage();
      state = state.copyWith(currentLanguage: defaultLanguage);
    } catch (e) {
      // Handle error silently
    }
  }

  List<Map<String, String>> getAvailableLanguages() {
    return _languageNames.entries.map((e) => {'code': e.key, 'name': e.value}).toList();
  }

  String getLanguageName(String code) {
    return _languageNames[code] ?? 'English';
  }

  bool _isValidLanguageCode(String code) {
    return _service.getSupportedLanguages().contains(code);
  }
}

class InformationNotifier extends Notifier<InformationState> {
  InformationService get _service => ref.read(informationServiceProvider);

  @override
  InformationState build() {
    Future.microtask(() => _loadAppInformation());
    return const InformationState();
  }

  Future<void> _loadAppInformation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final appVersion = await _service.getAppVersion();
      final versionOnly = await _service.getVersionOnly();
      final buildNumber = await _service.getBuildNumber();
      final packageName = await _service.getPackageName();
      final appNameFromPackage = await _service.getAppNameFromPackage();
      final appDescription = _service.getAppDescription();
      final developerName = _service.getDeveloperName();

      state = state.copyWith(
        appVersion: appVersion,
        versionOnly: versionOnly,
        buildNumber: buildNumber,
        packageName: packageName,
        appName: appNameFromPackage,
        appDescription: appDescription,
        developerName: developerName,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAppInformation() async {
    await _loadAppInformation();
  }

  Future<bool> launchUrl(String url) async {
    try {
      final success = await _service.launchExternalUrl(url);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> launchAppWebsite() async {
    return await _service.launchAppWebsite();
  }

  Future<bool> launchPrivacyPolicy() async {
    return await _service.launchPrivacyPolicy();
  }

  Future<bool> launchTermsOfService() async {
    return await _service.launchTermsOfService();
  }

  Future<bool> launchIngvWebsite() async {
    return await _service.launchIngvWebsite();
  }

  Future<bool> launchIngvApiDocumentation() async {
    return await _service.launchIngvApiDocumentation();
  }

  Map<String, String> getCredits() {
    return _service.getCredits();
  }

  Map<String, String> getLegalInfo() {
    return _service.getLegalInfo();
  }

  String getAppWebsite() {
    return _service.getAppWebsite();
  }

  String getPrivacyPolicyUrl() {
    return _service.getPrivacyPolicyUrl();
  }

  String getTermsOfServiceUrl() {
    return _service.getTermsOfServiceUrl();
  }

  String getIngvWebsite() {
    return _service.getIngvWebsite();
  }

  String getIngvApiUrl() {
    return _service.getIngvApiUrl();
  }
}

// ============================================================================
// MAIN PROVIDERS
// ============================================================================

final earthquakeListProvider = NotifierProvider<EarthquakeListNotifier, EarthquakeListState>(() {
  return EarthquakeListNotifier();
});

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

final defaultSettingsProvider = NotifierProvider<DefaultSettingsNotifier, DefaultSettingsState>(() {
  return DefaultSettingsNotifier();
});

final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(() {
  return LanguageNotifier();
});

final informationProvider = NotifierProvider<InformationNotifier, InformationState>(() {
  return InformationNotifier();
});

// Computed providers
final filteredEarthquakesProvider = Provider<List<EarthquakeFeature>>((ref) {
  final state = ref.watch(earthquakeListProvider);
  return state.earthquakes;
});

final earthquakeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final earthquakes = ref.watch(filteredEarthquakesProvider);
  final viewModel = ref.watch(earthquakeViewModelProvider);
  return viewModel.calculateEarthquakeStats(earthquakes);
});
