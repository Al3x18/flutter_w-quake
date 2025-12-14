import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/earthquake_filter.dart';
import '../models/earthquake_source.dart';

class SettingsStorageService {
  static const String _defaultFilterKey = 'default_filter_settings';
  static const String _isInitializedKey = 'settings_initialized';
  static const String _locationEnabledKey = 'location_enabled';
  static const String _showUserLocationKey = 'show_user_location';
  static const String _locationRadiusKmKey = 'location_radius_km';
  static const String _earthquakeSourceKey = 'earthquake_source';

  Future<void> saveEarthquakeSource(EarthquakeSource source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_earthquakeSourceKey, source.name);
      debugPrint(
        '[SettingsStorageService] Earthquake source saved: ${source.name}',
      );
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to save earthquake source: $e',
      );
      rethrow;
    }
  }

  Future<EarthquakeSource> loadEarthquakeSource() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sourceName = prefs.getString(_earthquakeSourceKey);
      if (sourceName == null) return EarthquakeSource.ingv;

      return EarthquakeSource.values.firstWhere(
        (e) => e.name == sourceName,
        orElse: () => EarthquakeSource.ingv,
      );
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to load earthquake source: $e',
      );
      return EarthquakeSource.ingv;
    }
  }

  Future<void> saveDefaultFilter(EarthquakeFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final filterJson = _filterToJson(filter);

      await prefs.setString(_defaultFilterKey, filterJson);
      await prefs.setBool(_isInitializedKey, true);

      debugPrint('[SettingsStorageService] Default filter saved successfully');
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to save default filter: $e',
      );
      rethrow;
    }
  }

  Future<EarthquakeFilter?> loadDefaultFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isInitialized = prefs.getBool(_isInitializedKey) ?? false;
      if (!isInitialized) {
        debugPrint('[SettingsStorageService] No saved settings found');
        return null;
      }

      final filterJson = prefs.getString(_defaultFilterKey);
      if (filterJson == null) {
        debugPrint('[SettingsStorageService] No filter data found');
        return null;
      }

      final filter = _jsonToFilter(filterJson);
      debugPrint('[SettingsStorageService] Default filter loaded successfully');

      return filter;
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to load default filter: $e',
      );
      return null;
    }
  }

  Future<bool> isInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isInitializedKey) ?? false;
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to check initialization: $e',
      );
      return false;
    }
  }

  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_defaultFilterKey);
      await prefs.remove(_isInitializedKey);
      await prefs.remove(_locationEnabledKey);
      await prefs.remove(_showUserLocationKey);
      await prefs.remove(_locationRadiusKmKey);
      await prefs.remove(_earthquakeSourceKey);
      debugPrint('[SettingsStorageService] Settings cleared successfully');
    } catch (e) {
      debugPrint('[SettingsStorageService ERROR] Failed to clear settings: $e');
      rethrow;
    }
  }

  Future<void> saveLocationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationEnabledKey, enabled);
      debugPrint(
        '[SettingsStorageService] Location enabled setting saved: $enabled',
      );
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to save location enabled: $e',
      );
      rethrow;
    }
  }

  Future<bool> loadLocationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_locationEnabledKey) ?? false;
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to load location enabled: $e',
      );
      return false;
    }
  }

  Future<void> saveShowUserLocation(bool show) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showUserLocationKey, show);
      debugPrint(
        '[SettingsStorageService] Show user location setting saved: $show',
      );
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to save show user location: $e',
      );
      rethrow;
    }
  }

  Future<bool> loadShowUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_showUserLocationKey) ?? false;
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to load show user location: $e',
      );
      return false;
    }
  }

  Future<void> saveLocationRadiusKm(int radiusKm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_locationRadiusKmKey, radiusKm);
      debugPrint(
        '[SettingsStorageService] Location radius saved: $radiusKm km',
      );
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to save location radius: $e',
      );
      rethrow;
    }
  }

  Future<int> loadLocationRadiusKm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_locationRadiusKmKey) ?? 100;
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to load location radius: $e',
      );
      return 100;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaultFilter = const EarthquakeFilter();
      await saveDefaultFilter(defaultFilter);
      debugPrint('[SettingsStorageService] Reset to defaults completed');
    } catch (e) {
      debugPrint(
        '[SettingsStorageService ERROR] Failed to reset to defaults: $e',
      );
      rethrow;
    }
  }

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
    final Map<String, dynamic> json = jsonDecode(jsonString);

    final areaName = json['area'] as String;
    final area = EarthquakeFilterArea.values.firstWhere(
      (a) => a.name == areaName,
      orElse: () => EarthquakeFilterArea.defaultArea,
    );

    DateTime? customStartDate;
    DateTime? customEndDate;

    if (json['customStartDate'] != null) {
      try {
        customStartDate = DateTime.parse(json['customStartDate']);
      } catch (e) {
        debugPrint(
          '[SettingsStorageService] Error parsing customStartDate: $e',
        );
      }
    }

    if (json['customEndDate'] != null) {
      try {
        customEndDate = DateTime.parse(json['customEndDate']);
      } catch (e) {
        debugPrint('[SettingsStorageService] Error parsing customEndDate: $e');
      }
    }

    return EarthquakeFilter(
      area: area,
      minMagnitude: (json['minMagnitude'] as num).toDouble(),
      daysBack: json['daysBack'] as int,
      useCustomDateRange: json['useCustomDateRange'] as bool,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
    );
  }
}
