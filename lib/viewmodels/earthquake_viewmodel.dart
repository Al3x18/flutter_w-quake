import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../models/earthquake_source.dart';
import '../services/earthquake_api_service.dart';

class EarthquakeViewModel {
  final EarthquakeApiService _apiService;

  EarthquakeViewModel({EarthquakeApiService? apiService})
    : _apiService = apiService ?? EarthquakeApiService();

  DateTime _parseUtcToLocal(String timeString) {
    String utcString = timeString.endsWith('Z') ? timeString : '${timeString}Z';
    final utcDateTime = DateTime.parse(utcString);
    return utcDateTime.toLocal();
  }

  String getDateCategory(String? timeString) {
    if (timeString == null) return 'previous';

    try {
      final localDateTime = _parseUtcToLocal(timeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final eventDate = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

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

  List<EarthquakeFeature> filterEarthquakesByMagnitude(
    List<EarthquakeFeature> earthquakes,
    double minMagnitude,
  ) {
    return earthquakes
        .where(
          (earthquake) => (earthquake.properties?.mag ?? 0.0) >= minMagnitude,
        )
        .toList();
  }

  List<EarthquakeFeature> sortEarthquakesByTime(
    List<EarthquakeFeature> earthquakes,
  ) {
    final sortedList = List<EarthquakeFeature>.from(earthquakes);
    sortedList.sort((a, b) {
      final timeA = a.properties?.time != null
          ? DateTime.parse(a.properties!.time!)
          : DateTime(1970);
      final timeB = b.properties?.time != null
          ? DateTime.parse(b.properties!.time!)
          : DateTime(1970);
      return timeB.compareTo(timeA);
    });
    return sortedList;
  }

  Map<String, dynamic> calculateEarthquakeStats(
    List<EarthquakeFeature> earthquakes,
  ) {
    if (earthquakes.isEmpty) {
      return {
        'total': 0,
        'maxMagnitude': 0.0,
        'minMagnitude': 0.0,
        'averageMagnitude': 0.0,
        'strongestEarthquake': null,
        'mostRecentEarthquake': null,
      };
    }

    final magnitudes = earthquakes
        .map((e) => e.properties?.mag ?? 0.0)
        .toList();
    final maxMagnitude = magnitudes.reduce((a, b) => a > b ? a : b);
    final minMagnitude = magnitudes.reduce((a, b) => a < b ? a : b);
    final averageMagnitude =
        magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    final strongestEarthquake = earthquakes.reduce(
      (a, b) => (a.properties?.mag ?? 0.0) > (b.properties?.mag ?? 0.0) ? a : b,
    );

    final mostRecentEarthquake = earthquakes.reduce((a, b) {
      final timeA = a.properties?.time != null
          ? DateTime.parse(a.properties!.time!)
          : DateTime(1970);
      final timeB = b.properties?.time != null
          ? DateTime.parse(b.properties!.time!)
          : DateTime(1970);
      return timeB.isAfter(timeA) ? b : a;
    });

    return {
      'total': earthquakes.length,
      'maxMagnitude': maxMagnitude,
      'minMagnitude': minMagnitude,
      'averageMagnitude': averageMagnitude,
      'strongestEarthquake': strongestEarthquake,
      'mostRecentEarthquake': mostRecentEarthquake,
    };
  }

  String getEarthquakeIntensityCategory(double magnitude) {
    if (magnitude >= 7.0) return 'Major';
    if (magnitude >= 6.0) return 'Strong';
    if (magnitude >= 5.0) return 'Moderate';
    if (magnitude >= 4.0) return 'Light';
    if (magnitude >= 3.0) return 'Minor';
    return 'Micro';
  }

  Color getMagnitudeColor(double magnitude) {
    if (magnitude >= 6.0) return const Color(0xFFD32F2F);
    if (magnitude >= 5.0) return const Color(0xFFEF5350);
    if (magnitude >= 4.0) return const Color(0xFFFB8C00);
    if (magnitude >= 3.0) return const Color(0xFFFDD835);
    if (magnitude >= 2.0) return const Color(0xFF4CAF50);
    return Colors.white;
  }

  String formatEarthquakeTime(String? timeString, AppLocalizations l10n) {
    if (timeString == null) return l10n.unknownDate;

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
          return l10n.hoursAgo(hours + 1);
        } else {
          if (hours == 1) {
            return l10n.oneHourAgo;
          } else {
            return l10n.hoursAgo(hours);
          }
        }
      } else if (difference.inMinutes > 0) {
        return l10n.minutesAgo(difference.inMinutes);
      } else {
        return l10n.now;
      }
    } catch (e) {
      return l10n.invalidDate;
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null) return '--:--';

    try {
      final localDateTime = _parseUtcToLocal(timeString);
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  String getTimeAgo(String? timeString, AppLocalizations l10n) {
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

  String formatDate(String? timeString) {
    if (timeString == null) return '--/--/----';

    try {
      final localDateTime = _parseUtcToLocal(timeString);
      return '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
    } catch (e) {
      return '--/--/----';
    }
  }

  String extractMainLocation(String place) {
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

  String extractSubLocation(String place) {
    if (place.contains('(') && place.contains(')')) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(place);
      if (match != null) {
        final subLocation = match.group(1) ?? '';

        if (place.contains('km')) {
          final distanceMatch = RegExp(r'(\d+\s*km\s*\w+)').firstMatch(place);
          if (distanceMatch != null) {
            return '${distanceMatch.group(1)}, $subLocation';
          }
        }

        return subLocation;
      }
    }

    if (place.contains('[') && place.contains(']')) {
      final match = RegExp(r'\[([^\]]+)\]').firstMatch(place);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }

  String extractProvince(String place) {
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

  String extractDistance(String place) {
    final distanceMatch = RegExp(r'(\d+\s*km\s*[A-Z]+)').firstMatch(place);
    if (distanceMatch != null) {
      return distanceMatch.group(1) ?? '';
    }

    return '';
  }

  bool isSignificantEarthquake(EarthquakeFeature earthquake) {
    return (earthquake.properties?.mag ?? 0.0) >= 4.0;
  }

  Map<String, List<EarthquakeFeature>> groupEarthquakesByRegion(
    List<EarthquakeFeature> earthquakes,
  ) {
    final Map<String, List<EarthquakeFeature>> grouped = {};

    for (final earthquake in earthquakes) {
      final place = earthquake.properties?.place ?? 'Unknown location';
      final region = _extractRegionFromPlace(place);

      if (!grouped.containsKey(region)) {
        grouped[region] = [];
      }
      grouped[region]!.add(earthquake);
    }

    return grouped;
  }

  /// This function is weird i know and probably not complete, should be refactored, but it works for now i think :)
  String _extractRegionFromPlace(String place) {
    if (place.contains('Sicilia') || place.contains('Siciliana')) {
      return 'Sicily';
    }
    if (place.contains('Calabria')) return 'Calabria';
    if (place.contains('Campania')) return 'Campania';
    if (place.contains('Lazio')) return 'Lazio';
    if (place.contains('Toscana')) return 'Tuscany';
    if (place.contains('Emilia') || place.contains('Romagna')) {
      return 'Emilia-Romagna';
    }
    if (place.contains('Lombardia')) return 'Lombardy';
    if (place.contains('Veneto')) return 'Veneto';
    if (place.contains('Piemonte')) return 'Piedmont';
    if (place.contains('Greece')) return 'Greece';
    if (place.contains('Albania')) return 'Albania';
    if (place.contains('Turkey')) return 'Turkey';
    if (place.contains('Iran')) return 'Iran';
    if (place.contains('Iraq')) return 'Iraq';
    if (place.contains('Israel')) return 'Israel';
    if (place.contains('Jordan')) return 'Jordan';
    if (place.contains('Lebanon')) return 'Lebanon';
    if (place.contains('Palestine')) return 'Palestine';
    if (place.contains('Syria')) return 'Syria';
    if (place.contains('Tunisia')) return 'Tunisia';
    if (place.contains('Algeria')) return 'Algeria';
    if (place.contains('Morocco')) return 'Morocco';
    if (place.contains('Libya')) return 'Libya';
    if (place.contains('Egypt')) return 'Egypt';
    if (place.contains('Sudan')) return 'Sudan';
    if (place.contains('Eritrea')) return 'Eritrea';
    if (place.contains('Somalia')) return 'Somalia';
    if (place.contains('Ethiopia')) return 'Ethiopia';
    if (place.contains('Kenya')) return 'Kenya';
    if (place.contains('Uganda')) return 'Uganda';
    if (place.contains('Rwanda')) return 'Rwanda';
    if (place.contains('Burundi')) return 'Burundi';
    if (place.contains('Tanzania')) return 'Tanzania';
    if (place.contains('Mozambique')) return 'Mozambique';
    if (place.contains('Zambia')) return 'Zambia';
    if (place.contains('Zimbabwe')) return 'Zimbabwe';
    if (place.contains('Namibia')) return 'Namibia';
    if (place.contains('Botswana')) return 'Botswana';
    if (place.contains('South Africa')) return 'South Africa';
    if (place.contains('Lesotho')) return 'Lesotho';
    if (place.contains('Swaziland')) return 'Swaziland';
    if (place.contains('Madagascar')) return 'Madagascar';
    if (place.contains('Mauritius')) return 'Mauritius';
    if (place.contains('Reunion')) return 'Reunion';
    if (place.contains('Mauritania')) return 'Mauritania';
    if (place.contains('Niger')) return 'Niger';
    if (place.contains('Chad')) return 'Chad';
    if (place.contains('Nigeria')) return 'Nigeria';
    if (place.contains('Cameroon')) return 'Cameroon';
    if (place.contains('Central African Republic')) return 'Central African Republic';
    if (place.contains('Chad')) return 'Chad';
    if (place.contains('Congo')) return 'Congo';
    if (place.contains('Congo Democratic Republic')) return 'Congo Democratic Republic';
    if (place.contains('Gabon')) return 'Gabon';
    if (place.contains('Equatorial Guinea')) return 'Equatorial Guinea';
    if (place.contains('Sao Tome and Principe')) return 'Sao Tome and Principe';
    if (place.contains('Benin')) return 'Benin';
    if (place.contains('Togo')) return 'Togo';
    if (place.contains('Burkina Faso')) return 'Burkina Faso';
    if (place.contains('Mali')) return 'Mali';
    if (place.contains('Senegal')) return 'Senegal';
    if (place.contains('Gambia')) return 'Gambia';
    if (place.contains('Guinea')) return 'Guinea';
    if (place.contains('Guinea-Bissau')) return 'Guinea-Bissau';
    if (place.contains('Liberia')) return 'Liberia';
    if (place.contains('Sierra Leone')) return 'Sierra Leone';
    if (place.contains('Ivory Coast')) return 'Ivory Coast';
    if (place.contains('Ghana')) return 'Ghana';
    if (place.contains('Togo')) return 'Togo';
    debugPrint('[EarthquakeViewModel] Unknown region: $place');
    return 'Other regions';
  }

  String getFilterDescription(EarthquakeFilter filter, AppLocalizations l10n) {
    final area = filter.area.getTranslatedName(l10n).toLowerCase();
    final magnitude = filter.minMagnitude;
    final daysBack = filter.daysBack;

    if (filter.useCustomDateRange) {
      if (filter.customStartDate != null && filter.customEndDate != null) {
        final startDate =
            '${filter.customStartDate!.day}/${filter.customStartDate!.month}/${filter.customStartDate!.year}';
        final endDate =
            '${filter.customEndDate!.day}/${filter.customEndDate!.month}/${filter.customEndDate!.year}';
        return l10n.eventsInAreaDateRange(area, startDate, endDate, magnitude);
      } else if (filter.customStartDate != null) {
        final startDate =
            '${filter.customStartDate!.day}/${filter.customStartDate!.month}/${filter.customStartDate!.year}';
        return l10n.eventsInAreaFromDate(area, startDate, magnitude);
      } else if (filter.customEndDate != null) {
        final endDate =
            '${filter.customEndDate!.day}/${filter.customEndDate!.month}/${filter.customEndDate!.year}';
        return l10n.eventsInAreaUntilDate(area, endDate, magnitude);
      }
    }

    if (daysBack == 1) {
      return l10n.eventsInAreaLast24Hours(area, magnitude);
    } else {
      return l10n.eventsInAreaLastDays(area, daysBack, magnitude);
    }
  }

  Future<List<EarthquakeFeature>> fetchEarthquakesWithFilters({
    String? startTime,
    String? endTime,
    double? minMagnitude,
    double? minLatitude,
    double? maxLatitude,
    double? minLongitude,
    double? maxLongitude,
  }) async {
    try {
      final response = await _apiService.getEarthquakes(
        startTime: startTime,
        endTime: endTime,
        minMagnitude: minMagnitude,
        minLatitude: minLatitude,
        maxLatitude: maxLatitude,
        minLongitude: minLongitude,
        maxLongitude: maxLongitude,
      );
      return response.features ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EarthquakeFeature>> fetchEarthquakesWithFilter(
    EarthquakeFilter filter, {
    EarthquakeSource source = EarthquakeSource.ingv,
  }) async {
    try {
      final params = filter.toApiParams();
      debugPrint('[EarthquakeViewModel] Filter params: $params');

      final response = await _apiService.getEarthquakes(
        startTime: params['starttime'],
        endTime: params['endtime'],
        minMagnitude: double.tryParse(params['minmagnitude'] ?? '2.0'),
        minLatitude: params['minlatitude'] != null
            ? double.tryParse(params['minlatitude']!)
            : null,
        maxLatitude: params['maxlatitude'] != null
            ? double.tryParse(params['maxlatitude']!)
            : null,
        minLongitude: params['minlongitude'] != null
            ? double.tryParse(params['minlongitude']!)
            : null,
        maxLongitude: params['maxlongitude'] != null
            ? double.tryParse(params['maxlongitude']!)
            : null,
        source: source,
      );

      debugPrint(
        '[EarthquakeViewModel] Fetched ${response.features?.length ?? 0} earthquakes',
      );
      return response.features ?? [];
    } catch (e) {
      debugPrint(
        '[EarthquakeViewModel ERROR] Error in fetchEarthquakesWithFilter: $e',
      );

      rethrow;
    }
  }

  List<EarthquakeFilterArea> getAvailableFilterAreas() {
    return EarthquakeFilterArea.values;
  }

  EarthquakeFilterArea? getFilterAreaByName(String name) {
    try {
      return EarthquakeFilterArea.values.firstWhere(
        (area) => area.name == name,
      );
    } catch (e) {
      return null;
    }
  }
}
