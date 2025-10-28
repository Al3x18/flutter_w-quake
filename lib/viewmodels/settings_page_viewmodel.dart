import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/earthquake_filter.dart';
import '../../services/settings_storage_service.dart';
import 'package:flutter/material.dart';

@immutable
class SettingsPageState {
  final EarthquakeFilter defaultFilter;
  final bool isLoading;
  final String? error;

  const SettingsPageState({
    this.defaultFilter = const EarthquakeFilter(),
    this.isLoading = false,
    this.error,
  });

  SettingsPageState copyWith({
    EarthquakeFilter? defaultFilter,
    bool? isLoading,
    String? error,
  }) {
    return SettingsPageState(
      defaultFilter: defaultFilter ?? this.defaultFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SettingsPageViewModel extends Notifier<SettingsPageState> {
  late final SettingsStorageService _storageService;

  @override
  SettingsPageState build() {
    _storageService = ref.read(settingsStorageServiceProvider);
    _loadSavedSettings();
    return const SettingsPageState(isLoading: true);
  }

  Future<void> _loadSavedSettings() async {
    final savedFilter = await _storageService.loadDefaultFilter();
    state = state.copyWith(
      defaultFilter: savedFilter ?? const EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1),
      isLoading: false,
    );
  }

  Future<String?> saveSettings(EarthquakeFilter filter) async {
    final dateError = validateDateRange(filter.customStartDate, filter.customEndDate);
    if (dateError != null) return dateError;

    final magError = validateMagnitude(filter.minMagnitude);
    if (magError != null) return magError;

    state = state.copyWith(isLoading: true);
    await _storageService.saveDefaultFilter(filter);
    state = state.copyWith(defaultFilter: filter, isLoading: false);
    return null;
  }

  Future<void> resetToDefaults() async {
    state = state.copyWith(isLoading: true);
    await _storageService.resetToDefaults();
    final defaultFilter = await _storageService.loadDefaultFilter() ?? const EarthquakeFilter(area: EarthquakeFilterArea.italy, minMagnitude: 2.0, daysBack: 1);
    state = state.copyWith(defaultFilter: defaultFilter, isLoading: false);
  }

  void updateArea(EarthquakeFilterArea area) {
    final newFilter = state.defaultFilter.copyWith(area: area);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void updateMinMagnitude(double magnitude) {
    final newFilter = state.defaultFilter.copyWith(minMagnitude: magnitude);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void updateUseCustomDateRange(bool useCustom) {
    final newFilter = state.defaultFilter.copyWith(useCustomDateRange: useCustom);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void updateDaysBack(int days) {
    final newFilter = state.defaultFilter.copyWith(daysBack: days);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void updateCustomStartDate(DateTime? date) {
    final newFilter = state.defaultFilter.copyWith(customStartDate: date);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void updateCustomEndDate(DateTime? date) {
    final newFilter = state.defaultFilter.copyWith(customEndDate: date);
    state = state.copyWith(defaultFilter: newFilter);
  }

  void resetCustomDates() {
    final newFilter = state.defaultFilter.copyWith(customStartDate: null, customEndDate: null);
    state = state.copyWith(defaultFilter: newFilter);
  }

  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return null;
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }
    final now = DateTime.now();
    if (startDate.isAfter(now) || endDate.isAfter(now)) {
      return 'Dates cannot be in the future';
    }
    if (endDate.difference(startDate).inDays > 3650) {
      return 'Date range cannot exceed 10 years';
    }
    return null;
  }

  String? validateMagnitude(double magnitude) {
    if (magnitude < 0.0 || magnitude > 10.0) {
      return 'Magnitude must be between 0.0 and 10.0';
    }
    return null;
  }

  List<EarthquakeFilterArea> getAvailableFilterAreas() => EarthquakeFilterArea.values;

  DateTime getMinimumDate() => DateTime(1985, 1, 1);

  DateTime getMaximumDate() => DateTime.now();
}

final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  return SettingsStorageService();
});
