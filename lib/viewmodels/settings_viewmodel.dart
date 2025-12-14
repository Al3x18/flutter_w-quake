import '../models/earthquake_filter.dart';
import '../utils/filter_validator.dart';

class SettingsViewModel {
  String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    return FilterValidator.validateDateRange(startDate, endDate);
  }

  String? validateMagnitude(double magnitude) {
    return FilterValidator.validateMagnitude(magnitude);
  }

  EarthquakeFilter createFilterFromSettings({
    required EarthquakeFilterArea area,
    required double minMagnitude,
    required int daysBack,
    required bool useCustomDateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return EarthquakeFilter(
      area: area,
      minMagnitude: minMagnitude,
      daysBack: daysBack,
      useCustomDateRange: useCustomDateRange,
      customStartDate: customStartDate,
      customEndDate: customEndDate,
    );
  }

  EarthquakeFilter getDefaultFilter() {
    return const EarthquakeFilter();
  }

  bool isCustomDateRangeValid(DateTime? startDate, DateTime? endDate) {
    return validateDateRange(startDate, endDate) == null;
  }

  DateTime getMinimumDate() => FilterValidator.getMinimumDate();

  DateTime getMaximumDate() => FilterValidator.getMaximumDate();

  List<EarthquakeFilterArea> getAvailableFilterAreas() =>
      FilterValidator.getAvailableFilterAreas();
}
