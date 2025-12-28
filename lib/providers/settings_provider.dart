import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake_filter.dart';
import '../models/earthquake_source.dart';

// --- State Class ---

class SettingsState {
  final EarthquakeFilter defaultFilter;
  final EarthquakeSource source;
  final bool isInitialized;
  final bool locationEnabled;
  final bool showUserLocation;
  final int locationRadiusKm;

  const SettingsState({
    this.defaultFilter = const EarthquakeFilter(
      area: EarthquakeFilterArea.italy,
      minMagnitude: 2.0,
      daysBack: 1,
      useCustomDateRange: false,
    ),
    this.source = EarthquakeSource.ingv,
    this.isInitialized = false,
    this.locationEnabled = false,
    this.showUserLocation = false,
    this.locationRadiusKm = 100,
  });

  SettingsState copyWith({
    EarthquakeFilter? defaultFilter,
    EarthquakeSource? source,
    bool? isInitialized,
    bool? locationEnabled,
    bool? showUserLocation,
    int? locationRadiusKm,
  }) {
    return SettingsState(
      defaultFilter: defaultFilter ?? this.defaultFilter,
      source: source ?? this.source,
      isInitialized: isInitialized ?? this.isInitialized,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      showUserLocation: showUserLocation ?? this.showUserLocation,
      locationRadiusKm: locationRadiusKm ?? this.locationRadiusKm,
    );
  }
}

// --- Notifier ---

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  static const String _defaultFilterKey = 'default_filter_settings';
  static const String _isInitializedKey = 'settings_initialized';
  static const String _locationEnabledKey = 'location_enabled';
  static const String _showUserLocationKey = 'show_user_location';
  static const String _locationRadiusKmKey = 'location_radius_km';
  static const String _earthquakeSourceKey = 'earthquake_source';

  @override
  Future<SettingsState> build() async {
    return _loadSettings();
  }

  Future<SettingsState> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isInitialized = prefs.getBool(_isInitializedKey) ?? false;
      final sourceName = prefs.getString(_earthquakeSourceKey);
      final EarthquakeSource source = sourceName != null 
          ? EarthquakeSource.values.firstWhere(
              (e) => e.name == sourceName,
              orElse: () => EarthquakeSource.ingv,
            )
          : EarthquakeSource.ingv;

      final locationEnabled = prefs.getBool(_locationEnabledKey) ?? false;
      final showUserLocation = prefs.getBool(_showUserLocationKey) ?? false;
      final locationRadiusKm = prefs.getInt(_locationRadiusKmKey) ?? 100;

      EarthquakeFilter filter = const EarthquakeFilter(
         area: EarthquakeFilterArea.italy,
         minMagnitude: 2.0,
         daysBack: 1,
         useCustomDateRange: false,
      );

      if (isInitialized) {
        final filterJson = prefs.getString(_defaultFilterKey);
        if (filterJson != null) {
          filter = _jsonToFilter(filterJson);
        }
      }

      return SettingsState(
        defaultFilter: filter,
        source: source,
        isInitialized: true,
        locationEnabled: locationEnabled,
        showUserLocation: showUserLocation,
        locationRadiusKm: locationRadiusKm,
      );
    } catch (e) {
      debugPrint('[SettingsNotifier] Error loading settings: $e');
      return const SettingsState(isInitialized: true); // Fallback to defaults
    }
  }

  // --- Actions ---

  Future<void> setDefaultFilter(EarthquakeFilter filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultFilterKey, _filterToJson(filter));
    await prefs.setBool(_isInitializedKey, true);
    
    // Update state optimistically or reload
    state = AsyncData(state.value!.copyWith(defaultFilter: filter));
  }

  Future<void> setEarthquakeSource(EarthquakeSource source) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_earthquakeSourceKey, source.name);
    state = AsyncData(state.value!.copyWith(source: source));
  }

  Future<void> setLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationEnabledKey, enabled);
    state = AsyncData(state.value!.copyWith(locationEnabled: enabled));
  }

  Future<void> setShowUserLocation(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showUserLocationKey, show);
    state = AsyncData(state.value!.copyWith(showUserLocation: show));
  }

  Future<void> setLocationRadiusKm(int radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_locationRadiusKmKey, radius);
    state = AsyncData(state.value!.copyWith(locationRadiusKm: radius));
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep location settings or reset? Usually reset applies to everything or just filters. 
    // Based on previous code, it only reset filter in one method, but let's be safe.
    // The previous `resetToDefaults` only reset the filter.
    
    const defaultFilter = EarthquakeFilter();
    await prefs.setString(_defaultFilterKey, _filterToJson(defaultFilter));
    
    state = AsyncData(state.value!.copyWith(defaultFilter: defaultFilter));
  }

  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Or specific keys
    state = const AsyncData(SettingsState(isInitialized: true));
  }

  // --- Helpers (Private) ---

  String _filterToJson(EarthquakeFilter filter) {
    final Map<String, dynamic> json = {
      'area': filter.area.name,
      'minMagnitude': filter.minMagnitude,
      'daysBack': filter.daysBack,
      'useCustomDateRange': filter.useCustomDateRange,
      'customStartDate': filter.customStartDate?.toIso8601String(),
      'customEndDate': filter.customEndDate?.toIso8601String(),
    };
    return jsonEncode(json);
  }

  EarthquakeFilter _jsonToFilter(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      final areaName = json['area'] as String;
      final area = EarthquakeFilterArea.values.firstWhere(
        (a) => a.name == areaName,
        orElse: () => EarthquakeFilterArea.defaultArea,
      );

      DateTime? customStartDate;
      if (json['customStartDate'] != null) {
        customStartDate = DateTime.tryParse(json['customStartDate']);
      }

      DateTime? customEndDate;
      if (json['customEndDate'] != null) {
        customEndDate = DateTime.tryParse(json['customEndDate']);
      }

      return EarthquakeFilter(
        area: area,
        minMagnitude: (json['minMagnitude'] as num).toDouble(),
        daysBack: json['daysBack'] as int,
        useCustomDateRange: json['useCustomDateRange'] as bool,
        customStartDate: customStartDate,
        customEndDate: customEndDate,
      );
    } catch (e) {
      debugPrint('[SettingsNotifier] Error parsing filter: $e');
      return const EarthquakeFilter();
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
