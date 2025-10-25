import '../models/earthquake_filter.dart';

/// ViewModel for Settings - handles validation and business logic for filters
class SettingsViewModel {
  // Date validation constants
  static const int _maxDateRangeDays = 3650; // 10 years
  static const double _minMagnitude = 0.0;
  static const double _maxMagnitude = 10.0;

  /// Validate date range settings
  /// Returns error message key if invalid, null if valid
  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return null;

    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }

    final now = DateTime.now();
    if (startDate.isAfter(now)) {
      return 'Start date cannot be in the future';
    }

    if (endDate.isAfter(now)) {
      return 'End date cannot be in the future';
    }

    final difference = endDate.difference(startDate);
    if (difference.inDays > _maxDateRangeDays) {
      return 'Date range cannot exceed 10 years';
    }

    return null;
  }

  /// Validate magnitude settings
  /// Returns error message key if invalid, null if valid
  String? validateMagnitude(double magnitude) {
    if (magnitude < _minMagnitude) {
      return 'Minimum magnitude cannot be negative';
    }

    if (magnitude > _maxMagnitude) {
      return 'Minimum magnitude cannot exceed $_maxMagnitude';
    }

    return null;
  }

  /// Create a new filter from settings
  EarthquakeFilter createFilterFromSettings({
    required EarthquakeFilterArea area,
    required double minMagnitude,
    required int daysBack,
    required bool useCustomDateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return EarthquakeFilter(area: area, minMagnitude: minMagnitude, daysBack: daysBack, useCustomDateRange: useCustomDateRange, customStartDate: customStartDate, customEndDate: customEndDate);
  }

  /// Get default filter
  EarthquakeFilter getDefaultFilter() {
    return const EarthquakeFilter();
  }

  /// Check if custom date range is valid
  bool isCustomDateRangeValid(DateTime? startDate, DateTime? endDate) {
    return validateDateRange(startDate, endDate) == null;
  }

  /// Get minimum date for date picker (API limitation: 1985-01-01)
  DateTime getMinimumDate() => DateTime(1985, 1, 1);

  /// Get maximum date for date picker (today)
  DateTime getMaximumDate() => DateTime.now();

  /// Get available filter areas
  List<EarthquakeFilterArea> getAvailableFilterAreas() => EarthquakeFilterArea.values;
}
