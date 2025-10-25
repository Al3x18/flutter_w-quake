import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../services/earthquake_api_service.dart';

class EarthquakeViewModel {
  final EarthquakeApiService _apiService;

  EarthquakeViewModel({EarthquakeApiService? apiService}) : _apiService = apiService ?? EarthquakeApiService();

  /// Helper method to parse UTC timestamp and convert to local timezone
  /// INGV API returns timestamps in UTC format (ISO 8601)
  DateTime _parseUtcToLocal(String timeString) {
    // Ensure the string is treated as UTC
    // If it doesn't end with 'Z', add it to force UTC interpretation
    String utcString = timeString.endsWith('Z') ? timeString : '${timeString}Z';
    final utcDateTime = DateTime.parse(utcString);
    return utcDateTime.toLocal();
  }

  /// Determine if the earthquake occurred today, yesterday, or on previous days
  String getDateCategory(String? timeString) {
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

  // Business logic for filtering earthquakes by magnitude
  List<EarthquakeFeature> filterEarthquakesByMagnitude(List<EarthquakeFeature> earthquakes, double minMagnitude) {
    return earthquakes.where((earthquake) => (earthquake.properties?.mag ?? 0.0) >= minMagnitude).toList();
  }

  // Business logic for sorting earthquakes by time (most recent first)
  List<EarthquakeFeature> sortEarthquakesByTime(List<EarthquakeFeature> earthquakes) {
    final sortedList = List<EarthquakeFeature>.from(earthquakes);
    sortedList.sort((a, b) {
      // Parse UTC times for comparison (no need to convert to local for sorting)
      final timeA = a.properties?.time != null ? DateTime.parse(a.properties!.time!) : DateTime(1970);
      final timeB = b.properties?.time != null ? DateTime.parse(b.properties!.time!) : DateTime(1970);
      return timeB.compareTo(timeA); // Most recent first
    });
    return sortedList;
  }

  // Business logic for calculating earthquake statistics
  Map<String, dynamic> calculateEarthquakeStats(List<EarthquakeFeature> earthquakes) {
    if (earthquakes.isEmpty) {
      return {'total': 0, 'maxMagnitude': 0.0, 'minMagnitude': 0.0, 'averageMagnitude': 0.0, 'strongestEarthquake': null, 'mostRecentEarthquake': null};
    }

    final magnitudes = earthquakes.map((e) => e.properties?.mag ?? 0.0).toList();
    final maxMagnitude = magnitudes.reduce((a, b) => a > b ? a : b);
    final minMagnitude = magnitudes.reduce((a, b) => a < b ? a : b);
    final averageMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;

    // Find strongest earthquake
    final strongestEarthquake = earthquakes.reduce((a, b) => (a.properties?.mag ?? 0.0) > (b.properties?.mag ?? 0.0) ? a : b);

    // Find most recent earthquake
    final mostRecentEarthquake = earthquakes.reduce((a, b) {
      // Parse UTC times for comparison (no need to convert to local for comparison)
      final timeA = a.properties?.time != null ? DateTime.parse(a.properties!.time!) : DateTime(1970);
      final timeB = b.properties?.time != null ? DateTime.parse(b.properties!.time!) : DateTime(1970);
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

  // Business logic for categorizing earthquake intensity
  String getEarthquakeIntensityCategory(double magnitude) {
    if (magnitude >= 7.0) return 'Major';
    if (magnitude >= 6.0) return 'Strong';
    if (magnitude >= 5.0) return 'Moderate';
    if (magnitude >= 4.0) return 'Light';
    if (magnitude >= 3.0) return 'Minor';
    return 'Micro';
  }

  // Business logic for determining earthquake color based on magnitude
  Color getMagnitudeColor(double magnitude) {
    if (magnitude >= 6.0) return const Color(0xFFD32F2F); // Red 600
    if (magnitude >= 5.0) return const Color(0xFFEF5350); // Red 400
    if (magnitude >= 4.0) return const Color(0xFFFB8C00); // Orange 600
    if (magnitude >= 3.0) return const Color(0xFFFDD835); // Yellow 600
    if (magnitude >= 2.0) return const Color(0xFF4CAF50); // Green 500
    return Colors.white; // White for low magnitude
  }

  // Business logic for formatting earthquake time
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

        // Round to half hours: 0-22min = no half, 23-52min = half, 53+ = next hour
        if (remainingMinutes >= 23 && remainingMinutes <= 52) {
          // Show with half hour (½)
          if (hours == 1) {
            return l10n.oneAndHalfHoursAgo; // "1½ hours ago"
          } else {
            return l10n.hoursAndHalfAgo(hours); // "2½ hours ago"
          }
        } else if (remainingMinutes > 52) {
          // Round up to next hour
          return l10n.hoursAgo(hours + 1);
        } else {
          // Show just the hours
          if (hours == 1) {
            return l10n.oneHourAgo; // "1 hour ago"
          } else {
            return l10n.hoursAgo(hours); // "2 hours ago"
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

  // Business logic for formatting time as "HH:MM" (local timezone)
  String formatTime(String? timeString) {
    if (timeString == null) return '--:--';

    try {
      final localDateTime = _parseUtcToLocal(timeString);
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  // Business logic for formatting time ago (local timezone)
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

        // Round to half hours: 0-22min = no half, 23-52min = half, 53+ = next hour
        if (remainingMinutes >= 23 && remainingMinutes <= 52) {
          // Show with half hour (½)
          if (hours == 1) {
            return l10n.oneAndHalfHoursAgo; // "1½ ore fa"
          } else {
            return l10n.hoursAndHalfAgo(hours); // "2½ ore fa"
          }
        } else if (remainingMinutes > 52) {
          // Round up to next hour
          return l10n.hrsAgo(hours + 1);
        } else {
          // Show just the hours
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

  // Business logic for formatting date as DD/MM/YYYY (local timezone)
  String formatDate(String? timeString) {
    if (timeString == null) return '--/--/----';

    try {
      final localDateTime = _parseUtcToLocal(timeString);
      return '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
    } catch (e) {
      return '--/--/----';
    }
  }

  // Business logic for extracting main location from place string
  String extractMainLocation(String place) {
    if (place.contains('(')) {
      final parts = place.split('(');
      if (parts.length > 1) {
        final mainPart = parts[0].trim();
        // If it contains distance info like "3 km SW", extract the city name
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

  // Business logic for extracting sub-location from place string
  String extractSubLocation(String place) {
    // First look for round brackets (province/municipality)
    if (place.contains('(') && place.contains(')')) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(place);
      if (match != null) {
        final subLocation = match.group(1) ?? '';

        // If it contains distance info, combine everything
        if (place.contains('km')) {
          final distanceMatch = RegExp(r'(\d+\s*km\s*\w+)').firstMatch(place);
          if (distanceMatch != null) {
            return '${distanceMatch.group(1)}, $subLocation';
          }
        }

        // Return only the province/municipality in brackets
        return subLocation;
      }
    }

    // Fallback for square brackets
    if (place.contains('[') && place.contains(']')) {
      final match = RegExp(r'\[([^\]]+)\]').firstMatch(place);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }

  // Business logic for extracting only province from place string
  String extractProvince(String place) {
    // Look for round brackets (province/municipality)
    if (place.contains('(') && place.contains(')')) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(place);
      if (match != null) {
        final content = match.group(1) ?? '';

        // If content contains distance (e.g. "3 km E, PR"), extract only the province
        if (content.contains(',')) {
          final parts = content.split(',');
          if (parts.length > 1) {
            return parts.last.trim(); // Take the last part (the province)
          }
        }

        // If it doesn't contain commas, it might be just the province
        return content;
      }
    }

    return '';
  }

  // Business logic for extracting distance info from place string
  String extractDistance(String place) {
    // Look for distance patterns like "3 km SW", "5 km E", etc.
    final distanceMatch = RegExp(r'(\d+\s*km\s*[A-Z]+)').firstMatch(place);
    if (distanceMatch != null) {
      return distanceMatch.group(1) ?? '';
    }

    return '';
  }

  // Business logic for determining if earthquake is significant
  bool isSignificantEarthquake(EarthquakeFeature earthquake) {
    return (earthquake.properties?.mag ?? 0.0) >= 4.0;
  }

  // Business logic for grouping earthquakes by region
  Map<String, List<EarthquakeFeature>> groupEarthquakesByRegion(List<EarthquakeFeature> earthquakes) {
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

  // Helper method to extract region from place string
  String _extractRegionFromPlace(String place) {
    // Simple region extraction logic
    if (place.contains('Sicilia') || place.contains('Siciliana')) return 'Sicily';
    if (place.contains('Calabria')) return 'Calabria';
    if (place.contains('Campania')) return 'Campania';
    if (place.contains('Lazio')) return 'Lazio';
    if (place.contains('Toscana')) return 'Tuscany';
    if (place.contains('Emilia') || place.contains('Romagna')) return 'Emilia-Romagna';
    if (place.contains('Lombardia')) return 'Lombardy';
    if (place.contains('Veneto')) return 'Veneto';
    if (place.contains('Piemonte')) return 'Piedmont';
    if (place.contains('Greece')) return 'Greece';
    if (place.contains('Albania')) return 'Albania';
    return 'Other regions';
  }

  // Business logic for generating filter description with translations
  String getFilterDescription(EarthquakeFilter filter, AppLocalizations l10n) {
    final area = filter.area.getTranslatedName(l10n).toLowerCase();
    final magnitude = filter.minMagnitude;
    final daysBack = filter.daysBack;

    if (filter.useCustomDateRange) {
      if (filter.customStartDate != null && filter.customEndDate != null) {
        final startDate = '${filter.customStartDate!.day}/${filter.customStartDate!.month}/${filter.customStartDate!.year}';
        final endDate = '${filter.customEndDate!.day}/${filter.customEndDate!.month}/${filter.customEndDate!.year}';
        return l10n.eventsInAreaDateRange(area, startDate, endDate, magnitude);
      } else if (filter.customStartDate != null) {
        final startDate = '${filter.customStartDate!.day}/${filter.customStartDate!.month}/${filter.customStartDate!.year}';
        return l10n.eventsInAreaFromDate(area, startDate, magnitude);
      } else if (filter.customEndDate != null) {
        final endDate = '${filter.customEndDate!.day}/${filter.customEndDate!.month}/${filter.customEndDate!.year}';
        return l10n.eventsInAreaUntilDate(area, endDate, magnitude);
      }
    }

    if (daysBack == 1) {
      return l10n.eventsInAreaLast24Hours(area, magnitude);
    } else {
      return l10n.eventsInAreaLastDays(area, daysBack, magnitude);
    }
  }

  // Business logic for fetching earthquakes with error handling

  // Business logic for fetching earthquakes with custom parameters
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
      // Re-throw the exception as-is since it already contains user-friendly messages
      rethrow;
    }
  }

  // Business logic for fetching earthquakes with filter object
  Future<List<EarthquakeFeature>> fetchEarthquakesWithFilter(EarthquakeFilter filter) async {
    try {
      final params = filter.toApiParams();
      debugPrint('[EarthquakeViewModel] Filter params: $params'); // Debug logging

      final response = await _apiService.getEarthquakes(
        startTime: params['starttime'],
        endTime: params['endtime'],
        minMagnitude: double.tryParse(params['minmagnitude'] ?? '2.0'),
        minLatitude: params['minlatitude'] != null ? double.tryParse(params['minlatitude']!) : null,
        maxLatitude: params['maxlatitude'] != null ? double.tryParse(params['maxlatitude']!) : null,
        minLongitude: params['minlongitude'] != null ? double.tryParse(params['minlongitude']!) : null,
        maxLongitude: params['maxlongitude'] != null ? double.tryParse(params['maxlongitude']!) : null,
      );

      debugPrint('[EarthquakeViewModel] Fetched ${response.features?.length ?? 0} earthquakes'); // Debug logging
      return response.features ?? [];
    } catch (e) {
      debugPrint('[EarthquakeViewModel ERROR] Error in fetchEarthquakesWithFilter: $e'); // Debug logging
      // Re-throw the exception as-is since it already contains user-friendly messages
      rethrow;
    }
  }

  // Business logic for getting available filter areas
  List<EarthquakeFilterArea> getAvailableFilterAreas() {
    return EarthquakeFilterArea.values;
  }

  // Business logic for getting filter area by name
  EarthquakeFilterArea? getFilterAreaByName(String name) {
    try {
      return EarthquakeFilterArea.values.firstWhere((area) => area.name == name);
    } catch (e) {
      return null;
    }
  }
}
