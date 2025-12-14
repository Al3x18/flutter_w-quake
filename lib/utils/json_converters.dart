import 'package:json_annotation/json_annotation.dart';

class TimeConverter implements JsonConverter<String?, dynamic> {
  const TimeConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        json,
        isUtc: true,
      ).toIso8601String();
    }
    return null;
  }

  @override
  dynamic toJson(String? object) => object;
}

class EventIdConverter implements JsonConverter<int?, dynamic> {
  const EventIdConverter();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is String) {
      return int.tryParse(json) ?? json.hashCode;
    }
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}
