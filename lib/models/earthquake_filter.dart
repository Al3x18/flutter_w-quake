enum EarthquakeFilterArea {
  // World: No geographic limits (global coverage)
  world(null, null, null, null),

  // Italy: From Lampedusa (35.5°N) to South Tyrol (47.1°N)
  //        From Aosta Valley (6.6°E) to Apulia (18.5°E)
  //        Includes Sicily, Sardinia, and all Italian territory
  italy(35.0, 47.0, 6.0, 19.0),

  // Europe: From Mediterranean (35°N) to Northern Scandinavia (71°N)
  //         From Iceland (-25°W) to Western Russia (45°E)
  //         Covers entire European continent including islands
  europe(35.0, 71.0, -25.0, 45.0),

  //mediterranean(30.0, 46.0, -6.0, 36.0),

  // Asia: From Southern Indonesia (-10°S) to Northern Siberia (77°N)
  //       From Turkey/Middle East (25°E) to Far East (180°E)
  //       Includes Middle East, Central Asia, Indian Subcontinent, China, Japan, SE Asia
  asia(-10.0, 77.0, 25.0, 180.0),

  // Americas: From Southern Patagonia (-60°S) to Northern Alaska (85°N)
  //           From Pacific (180°W) to Atlantic (-30°W)
  //           Covers North, Central, and South America
  americas(-60.0, 85.0, -180.0, -30.0);

  const EarthquakeFilterArea(this.minLat, this.maxLat, this.minLon, this.maxLon);

  // Geographic boundaries (minLat, maxLat, minLon, maxLon)
  final double? minLat; // Minimum latitude (South boundary)
  final double? maxLat; // Maximum latitude (North boundary)
  final double? minLon; // Minimum longitude (West boundary)
  final double? maxLon; // Maximum longitude (East boundary)

  // Coordinates for Italy (current default)
  static const EarthquakeFilterArea defaultArea = italy;

  /// Get the translated name for this area
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
    this.minMagnitude = 0.0, // Default for Italy
    this.daysBack = 1,
    this.customStartDate,
    this.customEndDate,
    this.useCustomDateRange = false,
  });

  EarthquakeFilter copyWith({EarthquakeFilterArea? area, double? minMagnitude, int? daysBack, DateTime? customStartDate, DateTime? customEndDate, bool? useCustomDateRange}) {
    return EarthquakeFilter(
      area: area ?? this.area,
      minMagnitude: minMagnitude ?? this.minMagnitude,
      daysBack: daysBack ?? this.daysBack,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      useCustomDateRange: useCustomDateRange ?? this.useCustomDateRange,
    );
  }

  // Generate API parameters
  Map<String, String> toApiParams() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (useCustomDateRange && customStartDate != null && customEndDate != null) {
      startDate = customStartDate!;
      endDate = customEndDate!;
    } else if (useCustomDateRange && customStartDate != null) {
      // Only start date set, use today as end date
      startDate = customStartDate!;
      endDate = now;
    } else if (useCustomDateRange && customEndDate != null) {
      // Only end date set, use 30 days ago as start date
      startDate = now.subtract(const Duration(days: 30));
      endDate = customEndDate!;
    } else {
      // Use the days back logic
      startDate = now.subtract(Duration(days: daysBack));
      endDate = now;
    }

    final params = <String, String>{
      'format': 'geojson',
      'starttime': startDate.toIso8601String().split('T')[0],
      'endtime': endDate.toIso8601String().split('T')[0],
      'minmagnitude': minMagnitude.toString(),
    };

    // Add geographic coordinates if specified
    if (area.minLat != null) params['minlatitude'] = area.minLat!.toString();
    if (area.maxLat != null) params['maxlatitude'] = area.maxLat!.toString();
    if (area.minLon != null) params['minlongitude'] = area.minLon!.toString();
    if (area.maxLon != null) params['maxlongitude'] = area.maxLon!.toString();

    return params;
  }
}
