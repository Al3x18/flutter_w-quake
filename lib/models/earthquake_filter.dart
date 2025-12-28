import '../l10n/app_localizations.dart';

enum EarthquakeFilterArea {
  world(null, null, null, null),

  italy(35.0, 47.0, 6.0, 19.0),

  europe(35.0, 71.0, -25.0, 45.0),

  asia(-10.0, 77.0, 25.0, 180.0),

  americas(-60.0, 85.0, -180.0, -30.0);

  const EarthquakeFilterArea(
    this.minLat,
    this.maxLat,
    this.minLon,
    this.maxLon,
  );

  final double? minLat;
  final double? maxLat;
  final double? minLon;
  final double? maxLon;

  static const EarthquakeFilterArea defaultArea = italy;

  String getTranslatedName(dynamic l10n) {
    switch (this) {
      case EarthquakeFilterArea.world:
        return l10n.world;
      case EarthquakeFilterArea.italy:
        return l10n.italy;
      case EarthquakeFilterArea.europe:
        return l10n.europe;
      case EarthquakeFilterArea.asia:
        return l10n.asia;
      case EarthquakeFilterArea.americas:
        return l10n.americas;
    }
  }
}

class EarthquakeFilter {
  final EarthquakeFilterArea area;
  final double minMagnitude;
  final int daysBack;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool useCustomDateRange;

  const EarthquakeFilter({
    this.area = EarthquakeFilterArea.defaultArea,
    this.minMagnitude = 0.0,
    this.daysBack = 1,
    this.customStartDate,
    this.customEndDate,
    this.useCustomDateRange = false,
  });

  EarthquakeFilter copyWith({
    EarthquakeFilterArea? area,
    double? minMagnitude,
    int? daysBack,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool? useCustomDateRange,
  }) {
    return EarthquakeFilter(
      area: area ?? this.area,
      minMagnitude: minMagnitude ?? this.minMagnitude,
      daysBack: daysBack ?? this.daysBack,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      useCustomDateRange: useCustomDateRange ?? this.useCustomDateRange,
    );
  }

  Map<String, String> toApiParams() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (useCustomDateRange &&
        customStartDate != null &&
        customEndDate != null) {
      startDate = customStartDate!;
      endDate = customEndDate!;
    } else if (useCustomDateRange && customStartDate != null) {
      startDate = customStartDate!;
      endDate = now;
    } else if (useCustomDateRange && customEndDate != null) {
      startDate = now.subtract(const Duration(days: 30));
      endDate = customEndDate!;
    } else {
      startDate = now.subtract(Duration(days: daysBack));
      endDate = now;
    }

    final params = <String, String>{
      'format': 'geojson',
      'starttime': startDate.toIso8601String().split('T')[0],
      'endtime': endDate.toIso8601String().split('T')[0],
      'minmagnitude': minMagnitude.toString(),
    };

    if (area.minLat != null) params['minlatitude'] = area.minLat!.toString();
    if (area.maxLat != null) params['maxlatitude'] = area.maxLat!.toString();
    if (area.minLon != null) params['minlongitude'] = area.minLon!.toString();
    if (area.maxLon != null) params['maxlongitude'] = area.maxLon!.toString();

    return params;
  }

  String getDescription(AppLocalizations l10n) {
    final areaName = area.getTranslatedName(l10n).toLowerCase();
    final magnitude = minMagnitude;
    final days = daysBack;

    if (useCustomDateRange) {
      if (customStartDate != null && customEndDate != null) {
        final startDate =
            '${customStartDate!.day}/${customStartDate!.month}/${customStartDate!.year}';
        final endDate =
            '${customEndDate!.day}/${customEndDate!.month}/${customEndDate!.year}';
        return l10n.eventsInAreaDateRange(
          areaName,
          startDate,
          endDate,
          magnitude,
        );
      } else if (customStartDate != null) {
        final startDate =
            '${customStartDate!.day}/${customStartDate!.month}/${customStartDate!.year}';
        return l10n.eventsInAreaFromDate(areaName, startDate, magnitude);
      } else if (customEndDate != null) {
        final endDate =
            '${customEndDate!.day}/${customEndDate!.month}/${customEndDate!.year}';
        return l10n.eventsInAreaUntilDate(areaName, endDate, magnitude);
      }
    }

    if (days == 1) {
      return l10n.eventsInAreaLast24Hours(areaName, magnitude);
    } else {
      return l10n.eventsInAreaLastDays(areaName, days, magnitude);
    }
  }
}