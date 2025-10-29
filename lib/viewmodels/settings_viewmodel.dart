import '../models/earthquake_filter.dart';
import '../utils/filter_validator.dart';

/// SettingsViewModel centralizes validation rules and helpers
/// for constructing `EarthquakeFilter` instances used by Settings.
///
/// It is stateless and safe to reuse across screens.
class SettingsViewModel {
  // Validation constraints
  // Delegated validations live in FilterValidator

  /// Validate the selected custom date range.
  /// Returns an error message (English) if invalid; returns null if valid.
  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    return FilterValidator.validateDateRange(startDate, endDate);
  }

  /// Validate the minimum magnitude value.
  /// Returns an error message (English) if invalid; returns null if valid.
  String? validateMagnitude(double magnitude) {
    return FilterValidator.validateMagnitude(magnitude);
  }

  /// Create a new `EarthquakeFilter` from Settings UI inputs.
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

  /// Return the default (empty) filter instance.
  EarthquakeFilter getDefaultFilter() {
    return const EarthquakeFilter();
  }

  /// Convenience helper to check custom date range validity.
  bool isCustomDateRangeValid(DateTime? startDate, DateTime? endDate) {
    return validateDateRange(startDate, endDate) == null;
  }

  /// Minimum date allowed by the data source (API limitation: 1985-01-01).
  DateTime getMinimumDate() => FilterValidator.getMinimumDate();

  /// Maximum date allowed for selection (today).
  DateTime getMaximumDate() => FilterValidator.getMaximumDate();

  /// List all available filter areas.
  List<EarthquakeFilterArea> getAvailableFilterAreas() => FilterValidator.getAvailableFilterAreas();
}
