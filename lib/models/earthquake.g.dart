// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Earthquake _$EarthquakeFromJson(Map<String, dynamic> json) => Earthquake(
  eventId: (json['eventId'] as num?)?.toInt(),
  originId: (json['originId'] as num?)?.toInt(),
  time: json['time'] as String?,
  author: json['author'] as String?,
  magType: json['magType'] as String?,
  mag: (json['mag'] as num?)?.toDouble(),
  magAuthor: json['magAuthor'] as String?,
  type: json['type'] as String?,
  place: json['place'] as String?,
  version: (json['version'] as num?)?.toInt(),
  geojsonCreationTime: json['geojson_creationTime'] as String?,
  geometry: json['geometry'] == null
      ? null
      : EarthquakeGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EarthquakeToJson(Earthquake instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'originId': instance.originId,
      'time': instance.time,
      'author': instance.author,
      'magType': instance.magType,
      'mag': instance.mag,
      'magAuthor': instance.magAuthor,
      'type': instance.type,
      'place': instance.place,
      'version': instance.version,
      'geojson_creationTime': instance.geojsonCreationTime,
      'geometry': instance.geometry,
    };

EarthquakeGeometry _$EarthquakeGeometryFromJson(Map<String, dynamic> json) =>
    EarthquakeGeometry(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$EarthquakeGeometryToJson(EarthquakeGeometry instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

EarthquakeResponse _$EarthquakeResponseFromJson(Map<String, dynamic> json) =>
    EarthquakeResponse(
      type: json['type'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => EarthquakeFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EarthquakeResponseToJson(EarthquakeResponse instance) =>
    <String, dynamic>{'type': instance.type, 'features': instance.features};

EarthquakeFeature _$EarthquakeFeatureFromJson(Map<String, dynamic> json) =>
    EarthquakeFeature(
      type: json['type'] as String?,
      properties: json['properties'] == null
          ? null
          : EarthquakeProperties.fromJson(
              json['properties'] as Map<String, dynamic>,
            ),
      geometry: json['geometry'] == null
          ? null
          : EarthquakeGeometry.fromJson(
              json['geometry'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EarthquakeFeatureToJson(EarthquakeFeature instance) =>
    <String, dynamic>{
      'type': instance.type,
      'properties': instance.properties,
      'geometry': instance.geometry,
    };

EarthquakeProperties _$EarthquakePropertiesFromJson(
  Map<String, dynamic> json,
) => EarthquakeProperties(
  eventId: (json['eventId'] as num?)?.toInt(),
  originId: (json['originId'] as num?)?.toInt(),
  time: json['time'] as String?,
  author: json['author'] as String?,
  magType: json['magType'] as String?,
  mag: (json['mag'] as num?)?.toDouble(),
  magAuthor: json['magAuthor'] as String?,
  type: json['type'] as String?,
  place: json['place'] as String?,
  version: (json['version'] as num?)?.toInt(),
  geojsonCreationTime: json['geojson_creationTime'] as String?,
);

Map<String, dynamic> _$EarthquakePropertiesToJson(
  EarthquakeProperties instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'originId': instance.originId,
  'time': instance.time,
  'author': instance.author,
  'magType': instance.magType,
  'mag': instance.mag,
  'magAuthor': instance.magAuthor,
  'type': instance.type,
  'place': instance.place,
  'version': instance.version,
  'geojson_creationTime': instance.geojsonCreationTime,
};
