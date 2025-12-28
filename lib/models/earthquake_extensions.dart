import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'earthquake.dart';

extension EarthquakePresentation on Earthquake {
  double get longitude => geometry?.longitude ?? 0.0;
  double get latitude => geometry?.latitude ?? 0.0;
  double get depth => geometry?.depth ?? 0.0;

  String get formattedTime {
    return _formatTime(time);
  }

  String get formattedDateTime {
    return _formatDateTime(time);
  }

  String getTimeAgo(AppLocalizations l10n) {
    return _getTimeAgo(time, l10n);
  }

  String getMagnitudeDescription(AppLocalizations l10n) {
    return _getMagnitudeDescription(mag ?? 0.0, l10n);
  }

  String getDepthDescription(AppLocalizations l10n) {
    return _getDepthDescription(depth, l10n);
  }

  String getIntensityLevel(AppLocalizations l10n) {
    return _getIntensityLevel(mag ?? 0.0, l10n);
  }

  Color get magnitudeColor {
    return _getMagnitudeColor(mag ?? 0.0);
  }

  String get formattedMagnitude => '${mag?.toStringAsFixed(1) ?? 'N/A'} ${magType ?? ''}';

  String get formattedDepth => '${depth.toStringAsFixed(1)} km';

  String get formattedCoordinates {
    final lat = latitude;
    final lon = longitude;

    final latStr = lat >= 0 ? '${lat.toStringAsFixed(4)}°N' : '${(-lat).toStringAsFixed(4)}°S';
    final lonStr = lon >= 0 ? '${lon.toStringAsFixed(4)}°E' : '${(-lon).toStringAsFixed(4)}°W';

    return '$latStr, $lonStr';
  }

  String get formattedCoordinatesDecimal {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String get formattedCoordinatesDMS {
    final latDMS = _decimalToDMS(latitude, true);
    final lonDMS = _decimalToDMS(longitude, false);
    return '$latDMS, $lonDMS';
  }

  String get mainLocation => _extractMainLocation(place ?? '');
  String get province => _extractProvince(place ?? '');
  String get distance => _extractDistance(place ?? '');

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

  String get magnitudeUncertainty => '';
  String get depthUncertainty => '';
  String? get stationCount => null;
  String? get phaseCount => null;

  bool get isRecent {
    if (time == null) return false;
    try {
      final dateTime = DateTime.parse(time!);
      final now = DateTime.now();
      return now.difference(dateTime).inHours < 1;
    } catch (e) {
      return false;
    }
  }
}

extension EarthquakeFeaturePresentation on EarthquakeFeature {
  String get formattedTime {
    return _formatTime(properties?.time);
  }

  String get formattedDate {
    return _formatDate(properties?.time);
  }

  String getTimeAgo(AppLocalizations l10n) {
    return _getTimeAgo(properties?.time, l10n);
  }

  String getDateCategory() {
    return _getDateCategory(properties?.time);
  }

  Color get magnitudeColor {
    return _getMagnitudeColor(properties?.mag ?? 0.0);
  }

  String get mainLocation => _extractMainLocation(properties?.place ?? '');
  String get province => _extractProvince(properties?.place ?? '');
  String get distance => _extractDistance(properties?.place ?? '');
}

extension EarthquakeListExtension on List<EarthquakeFeature> {
  List<EarthquakeFeature> sortedByTime() {
    final sortedList = List<EarthquakeFeature>.from(this);
    sortedList.sort((a, b) {
      final timeA = a.properties?.time != null ? DateTime.parse(a.properties!.time!) : DateTime(1970);
      final timeB = b.properties?.time != null ? DateTime.parse(b.properties!.time!) : DateTime(1970);
      return timeB.compareTo(timeA);
    });
    return sortedList;
  }

  Map<String, dynamic> calculateStats() {
    if (isEmpty) {
      return {'total': 0, 'maxMagnitude': 0.0, 'minMagnitude': 0.0, 'averageMagnitude': 0.0, 'strongestEarthquake': null, 'mostRecentEarthquake': null};
    }

    final magnitudes = map((e) => e.properties?.mag ?? 0.0).toList();
    final maxMagnitude = magnitudes.reduce((a, b) => a > b ? a : b);
    final minMagnitude = magnitudes.reduce((a, b) => a < b ? a : b);
    final averageMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    final strongestEarthquake = reduce((a, b) => (a.properties?.mag ?? 0.0) > (b.properties?.mag ?? 0.0) ? a : b);

    final mostRecentEarthquake = reduce((a, b) {
      final timeA = a.properties?.time != null ? DateTime.parse(a.properties!.time!) : DateTime(1970);
      final timeB = b.properties?.time != null ? DateTime.parse(b.properties!.time!) : DateTime(1970);
      return timeB.isAfter(timeA) ? b : a;
    });

    return {
      'total': length,
      'maxMagnitude': maxMagnitude,
      'minMagnitude': minMagnitude,
      'averageMagnitude': averageMagnitude,
      'strongestEarthquake': strongestEarthquake,
      'mostRecentEarthquake': mostRecentEarthquake,
    };
  }
}

String _getDateCategory(String? timeString) {
  if (timeString == null) return 'previous';

  try {
    final localDateTime = _parseUtcToLocal(timeString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(localDateTime.year, localDateTime.month, localDateTime.day);

    if (eventDate == today) {
      return 'today';
    } else if (eventDate == yesterday) {
      return 'yesterday';
    } else {
      return 'previous';
    }
  } catch (e) {
    return 'previous';
  }
}

DateTime _parseUtcToLocal(String timeString) {
  String utcString = timeString.endsWith('Z') ? timeString : '${timeString}Z';
  final utcDateTime = DateTime.parse(utcString);
  return utcDateTime.toLocal();
}

String _formatTime(String? timeString) {
  if (timeString == null) return '--:--';
  try {
    final localDateTime = _parseUtcToLocal(timeString);
    return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return '--:--';
  }
}

String _formatDate(String? timeString) {
  if (timeString == null) return '--/--/----';
  try {
    final localDateTime = _parseUtcToLocal(timeString);
    return '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
  } catch (e) {
    return '--/--/----';
  }
}

String _formatDateTime(String? timeString) {
  if (timeString == null) return 'N/A';
  try {
    final dateTime = DateTime.parse(timeString);
    final formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
    return '${formatter.format(dateTime)} CET';
  } catch (e) {
    return 'N/A';
  }
}

String _getTimeAgo(String? timeString, AppLocalizations l10n) {
  if (timeString == null) return l10n.unknown;

  try {
    final localDateTime = _parseUtcToLocal(timeString);
    final now = DateTime.now();
    final difference = now.difference(localDateTime);

    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      final totalMinutes = difference.inMinutes;
      final hours = totalMinutes ~/ 60;
      final remainingMinutes = totalMinutes % 60;

      if (remainingMinutes >= 23 && remainingMinutes <= 52) {
        if (hours == 1) {
          return l10n.oneAndHalfHoursAgo;
        } else {
          return l10n.hoursAndHalfAgo(hours);
        }
      } else if (remainingMinutes > 52) {
        return l10n.hrsAgo(hours + 1);
      } else {
        return l10n.hrsAgo(hours);
      }
    } else if (difference.inMinutes > 0) {
      return l10n.minsAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  } catch (e) {
    return l10n.unknown;
  }
}

Color _getMagnitudeColor(double magnitude) {
  if (magnitude >= 6.0) return const Color(0xFFD32F2F);
  if (magnitude >= 5.0) return const Color(0xFFEF5350);
  if (magnitude >= 4.0) return const Color(0xFFFB8C00);
  if (magnitude >= 3.0) return const Color(0xFFFDD835);
  if (magnitude >= 2.0) return const Color(0xFF4CAF50);
  return Colors.white;
}

String _getIntensityLevel(double magnitude, AppLocalizations l10n) {
  if (magnitude >= 7.0) return l10n.intensityVeryStrong;
  if (magnitude >= 6.0) return l10n.intensityStrong;
  if (magnitude >= 5.0) return l10n.intensityModerate;
  if (magnitude >= 4.0) return l10n.intensityLight;
  if (magnitude >= 3.0) return l10n.intensityWeak;
  return l10n.intensityMicro;
}

String _getMagnitudeDescription(double magnitude, AppLocalizations l10n) {
  if (magnitude >= 6.0) return l10n.magnitudeStrong;
  if (magnitude >= 5.0) return l10n.magnitudeModerate;
  if (magnitude >= 4.0) return l10n.magnitudeLight;
  if (magnitude >= 3.0) return l10n.magnitudeMinor;
  return l10n.magnitudeMicro;
}

String _getDepthDescription(double depth, AppLocalizations l10n) {
  if (depth >= 70) return l10n.depthDeep;
  if (depth >= 30) return l10n.depthIntermediate;
  return l10n.depthShallow;
}

String _decimalToDMS(double decimal, bool isLatitude) {
  final abs = decimal.abs();
  final degrees = abs.floor();
  final minutesFloat = (abs - degrees) * 60;
  final minutes = minutesFloat.floor();
  final seconds = (minutesFloat - minutes) * 60;

  final direction = isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');

  return '$degrees°$minutes\'${seconds.toStringAsFixed(1)}"$direction';
}

String _extractMainLocation(String place) {
  if (place.contains('(')) {
    final parts = place.split('(');
    if (parts.length > 1) {
      final mainPart = parts[0].trim();

      if (mainPart.contains('km')) {
        final cityMatch = RegExp(r'(\w+)\s*$').firstMatch(mainPart);
        if (cityMatch != null) {
          return cityMatch.group(1) ?? mainPart;
        }
      }
      return mainPart;
    }
  }

  if (place.contains('[')) {
    return place.split('[')[0].trim();
  }

  return place;
}

String _extractProvince(String place) {
  if (place.contains('(') && place.contains(')')) {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(place);
    if (match != null) {
      final content = match.group(1) ?? '';

      if (content.contains(',')) {
        final parts = content.split(',');
        if (parts.length > 1) {
          return parts.last.trim();
        }
      }

      return content;
    }
  }

  return '';
}

String _extractDistance(String place) {
  final distanceMatch = RegExp(r'(\d+\s*km\s*[A-Z]+)').firstMatch(place);
  if (distanceMatch != null) {
    return distanceMatch.group(1) ?? '';
  }

  return '';
}
