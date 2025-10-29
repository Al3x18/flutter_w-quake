import '../models/earthquake_filter.dart';

/// FilterValidator centralizes validation and constraints for earthquake filters.
class FilterValidator {
  static const int _maxDateRangeDays = 3650; // 10 years
  static const double _minMagnitude = 0.0;
  static const double _maxMagnitude = 10.0;

  /// Validate the selected custom date range.
  /// Returns an error message (English) if invalid; returns null if valid.
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
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

  /// Validate the minimum magnitude value.
  /// Returns an error message (English) if invalid; returns null if valid.
  static String? validateMagnitude(double magnitude) {
    if (magnitude < _minMagnitude) {
      return 'Minimum magnitude cannot be negative';
    }

    if (magnitude > _maxMagnitude) {
      return 'Minimum magnitude cannot exceed $_maxMagnitude';
    }

    return null;
  }

  /// Minimum date allowed by the data source (API limitation: 1985-01-01).
  static DateTime getMinimumDate() => DateTime(1985, 1, 1);

  /// Maximum date allowed for selection (today).
  static DateTime getMaximumDate() => DateTime.now();

  /// List all available filter areas.
  static List<EarthquakeFilterArea> getAvailableFilterAreas() => EarthquakeFilterArea.values;
}
