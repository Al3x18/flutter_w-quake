import '../models/earthquake_filter.dart';

class FilterValidator {
  static const int _maxDateRangeDays = 3650;
  static const double _minMagnitude = 0.0;
  static const double _maxMagnitude = 10.0;

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

  static String? validateMagnitude(double magnitude) {
    if (magnitude < _minMagnitude) {
      return 'Minimum magnitude cannot be negative';
    }

    if (magnitude > _maxMagnitude) {
      return 'Minimum magnitude cannot exceed $_maxMagnitude';
    }

    return null;
  }

  static DateTime getMinimumDate() => DateTime(1985, 1, 1);

  static DateTime getMaximumDate() => DateTime.now();

  static List<EarthquakeFilterArea> getAvailableFilterAreas() =>
      EarthquakeFilterArea.values;
}
