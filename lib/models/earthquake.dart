import 'package:json_annotation/json_annotation.dart';
import '../utils/json_converters.dart';

part 'earthquake.g.dart';

@JsonSerializable()
class Earthquake {
  final int? eventId;
  final String? eventIdString;
  final int? originId;
  @TimeConverter()
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

  const Earthquake({
    this.eventId,
    this.eventIdString,
    this.originId,
    this.time,
    this.author,
    this.magType,
    this.mag,
    this.magAuthor,
    this.type,
    this.place,
    this.version,
    this.geojsonCreationTime,
    this.geometry,
  });

  String get uniqueId => eventIdString ?? eventId?.toString() ?? '';

  factory Earthquake.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeToJson(this);
}

@JsonSerializable()
class EarthquakeGeometry {
  final String? type;
  final List<double>? coordinates;

  const EarthquakeGeometry({this.type, this.coordinates});

  factory EarthquakeGeometry.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeGeometryFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeGeometryToJson(this);

  double get longitude => coordinates?[0] ?? 0.0;
  double get latitude => coordinates?[1] ?? 0.0;
  double get depth =>
      coordinates != null && coordinates!.length > 2 ? coordinates![2] : 0.0;
}

@JsonSerializable()
class EarthquakeResponse {
  final String? type;
  final List<EarthquakeFeature>? features;

  const EarthquakeResponse({this.type, this.features});

  factory EarthquakeResponse.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeResponseToJson(this);
}

@JsonSerializable()
class EarthquakeFeature {
  final String? type;
  final String? id;
  final EarthquakeProperties? properties;
  final EarthquakeGeometry? geometry;

  const EarthquakeFeature({this.type, this.id, this.properties, this.geometry});

  factory EarthquakeFeature.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeFeatureFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeFeatureToJson(this);
}

@JsonSerializable()
class EarthquakeProperties {
  final int? eventId;
  final int? originId;
  @TimeConverter()
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

  const EarthquakeProperties({
    this.eventId,
    this.originId,
    this.time,
    this.author,
    this.magType,
    this.mag,
    this.magAuthor,
    this.type,
    this.place,
    this.version,
    this.geojsonCreationTime,
  });

  factory EarthquakeProperties.fromJson(Map<String, dynamic> json) {
    if (json['time'] is int) {
      final newJson = Map<String, dynamic>.from(json);
      newJson['time'] = DateTime.fromMillisecondsSinceEpoch(
        json['time'] as int,
        isUtc: true,
      ).toIso8601String();
      return _$EarthquakePropertiesFromJson(newJson);
    }
    return _$EarthquakePropertiesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$EarthquakePropertiesToJson(this);
}

extension EarthquakeExtensions on Earthquake {
  double get longitude => geometry?.longitude ?? 0.0;
  double get latitude => geometry?.latitude ?? 0.0;
  double get depth => geometry?.depth ?? 0.0;

  String get formattedMagnitude =>
      '${mag?.toStringAsFixed(1) ?? 'N/A'} ${magType ?? ''}';
  String get formattedDepth => '${depth.toStringAsFixed(1)} km';

  String get mainLocation {
    if (place == null) return 'Unknown Location';

    final parts = place!.split(',');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return place!;
  }

  String get province {
    if (place == null) return '';

    final regex = RegExp(r'\(([A-Z]{2})\)');
    final match = regex.firstMatch(place!);
    return match?.group(1) ?? '';
  }

  String get distance {
    if (place == null) return '';

    final regex = RegExp(r'(\d+\s*km\s*[NSEW]+)');
    final match = regex.firstMatch(place!);
    return match?.group(1) ?? '';
  }

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
