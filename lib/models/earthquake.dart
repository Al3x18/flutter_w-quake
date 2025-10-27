import 'package:json_annotation/json_annotation.dart';

part 'earthquake.g.dart';

@JsonSerializable()
class Earthquake {
  final int? eventId;
  final int? originId;
  final String? time;
  final String? author;
  final String? magType;
  final double? mag;
  @JsonKey(name: 'magAuthor')
  final String? magAuthor;
  final String? type;
  final String? place;
  final int? version;
  @JsonKey(name: 'geojson_creationTime')
  final String? geojsonCreationTime;
  final EarthquakeGeometry? geometry;

  const Earthquake({this.eventId, this.originId, this.time, this.author, this.magType, this.mag, this.magAuthor, this.type, this.place, this.version, this.geojsonCreationTime, this.geometry});

  factory Earthquake.fromJson(Map<String, dynamic> json) => _$EarthquakeFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeToJson(this);
}

@JsonSerializable()
class EarthquakeGeometry {
  final String? type;
  final List<double>? coordinates;

  const EarthquakeGeometry({this.type, this.coordinates});

  factory EarthquakeGeometry.fromJson(Map<String, dynamic> json) => _$EarthquakeGeometryFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeGeometryToJson(this);

  double get longitude => coordinates?[0] ?? 0.0;
  double get latitude => coordinates?[1] ?? 0.0;
  double get depth => coordinates != null && coordinates!.length > 2 ? coordinates![2] : 0.0;
}

@JsonSerializable()
class EarthquakeResponse {
  final String? type;
  final List<EarthquakeFeature>? features;

  const EarthquakeResponse({this.type, this.features});

  factory EarthquakeResponse.fromJson(Map<String, dynamic> json) => _$EarthquakeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeResponseToJson(this);
}

@JsonSerializable()
class EarthquakeFeature {
  final String? type;
  final EarthquakeProperties? properties;
  final EarthquakeGeometry? geometry;

  const EarthquakeFeature({this.type, this.properties, this.geometry});

  factory EarthquakeFeature.fromJson(Map<String, dynamic> json) => _$EarthquakeFeatureFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeFeatureToJson(this);
}

@JsonSerializable()
class EarthquakeProperties {
  final int? eventId;
  final int? originId;
  final String? time;
  final String? author;
  final String? magType;
  final double? mag;
  @JsonKey(name: 'magAuthor')
  final String? magAuthor;
  final String? type;
  final String? place;
  final int? version;
  @JsonKey(name: 'geojson_creationTime')
  final String? geojsonCreationTime;

  const EarthquakeProperties({this.eventId, this.originId, this.time, this.author, this.magType, this.mag, this.magAuthor, this.type, this.place, this.version, this.geojsonCreationTime});

  factory EarthquakeProperties.fromJson(Map<String, dynamic> json) => _$EarthquakePropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakePropertiesToJson(this);
}

// Extension to add helper methods to Earthquake class
extension EarthquakeExtensions on Earthquake {
  // Helper getters for easier access
  double get longitude => geometry?.longitude ?? 0.0;
  double get latitude => geometry?.latitude ?? 0.0;
  double get depth => geometry?.depth ?? 0.0;

  // Format methods for display
  String get formattedMagnitude => '${mag?.toStringAsFixed(1) ?? 'N/A'} ${magType ?? ''}';
  String get formattedDepth => '${depth.toStringAsFixed(1)} km';

  // Extract location components
  String get mainLocation {
    if (place == null) return 'Unknown Location';

    // Extract main location (before comma or parenthesis)
    final parts = place!.split(',');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return place!;
  }

  String get province {
    if (place == null) return '';

    // Look for province in parentheses like "(MC)" or "(TV)"
    final regex = RegExp(r'\(([A-Z]{2})\)');
    final match = regex.firstMatch(place!);
    return match?.group(1) ?? '';
  }

  String get distance {
    if (place == null) return '';

    // Extract distance information like "3 km NE"
    final regex = RegExp(r'(\d+\s*km\s*[NSEW]+)');
    final match = regex.firstMatch(place!);
    return match?.group(1) ?? '';
  }

  // Review status based on author
  String get reviewStatus {
    if (author == null) return 'UNKNOWN';

    if (author!.contains('SURVEY')) {
      return 'MANUAL / REVIEWED';
    } else if (author!.contains('AUTOMATIC')) {
      return 'AUTOMATIC';
    } else {
      return 'MANUAL / REVIEWED';
    }
  }

  // Get agency name
  String get agency {
    if (author == null) return 'UNKNOWN';

    if (author!.contains('INGV')) {
      return 'INGV';
    } else if (author!.contains('SURVEY')) {
      return 'INGV';
    } else {
      return author!;
    }
  }
}
