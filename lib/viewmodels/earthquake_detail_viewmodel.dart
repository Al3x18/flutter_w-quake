import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/earthquake.dart';
import '../l10n/app_localizations.dart';

class EarthquakeDetailViewModel {
  final Earthquake earthquake;

  EarthquakeDetailViewModel({required this.earthquake});

  // Format time only (HH:MM:SS)
  String formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Format date and time
  String formatDateTime(String? timeString) {
    if (timeString == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(timeString);
      final formatter = DateFormat('dd MMM yyyy \'at\' HH:mm:ss');
      return '${formatter.format(dateTime)} CET';
    } catch (e) {
      return 'N/A';
    }
  }

  // Get time ago
  String getTimeAgo(String? timeString, AppLocalizations l10n) {
    if (timeString == null) return 'N/A';

    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? l10n.dayAgo : l10n.daysAgo(difference.inDays)}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? l10n.oneHourAgo : l10n.hoursAgo(difference.inHours)}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? l10n.minuteAgo : l10n.minutesAgo(difference.inMinutes)}';
      } else {
        return l10n.justNow;
      }
    } catch (e) {
      return 'N/A';
    }
  }

  // Get magnitude color
  Color getMagnitudeColor(double magnitude) {
    if (magnitude >= 6.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 4.0) return Colors.yellow;
    if (magnitude >= 3.0) return Colors.lightGreen;
    return Colors.green;
  }

  // Get magnitude description
  String getMagnitudeDescription(double magnitude, AppLocalizations l10n) {
    if (magnitude >= 6.0) return l10n.magnitudeStrong;
    if (magnitude >= 5.0) return l10n.magnitudeModerate;
    if (magnitude >= 4.0) return l10n.magnitudeLight;
    if (magnitude >= 3.0) return l10n.magnitudeMinor;
    return l10n.magnitudeMicro;
  }

  // Get depth description
  String getDepthDescription(double depth, AppLocalizations l10n) {
    if (depth >= 70) return l10n.depthDeep;
    if (depth >= 30) return l10n.depthIntermediate;
    return l10n.depthShallow;
  }

  // Format coordinates with more precision
  String formatCoordinates() {
    final lat = earthquake.latitude;
    final lon = earthquake.longitude;

    // Format with appropriate precision based on location
    final latStr = lat >= 0 ? '${lat.toStringAsFixed(4)}°N' : '${(-lat).toStringAsFixed(4)}°S';
    final lonStr = lon >= 0 ? '${lon.toStringAsFixed(4)}°E' : '${(-lon).toStringAsFixed(4)}°W';

    return '$latStr, $lonStr';
  }

  // Format coordinates in decimal degrees
  String formatCoordinatesDecimal() {
    return '${earthquake.latitude.toStringAsFixed(6)}, ${earthquake.longitude.toStringAsFixed(6)}';
  }

  // Format coordinates in DMS (Degrees, Minutes, Seconds)
  String formatCoordinatesDMS() {
    final lat = earthquake.latitude;
    final lon = earthquake.longitude;

    final latDMS = _decimalToDMS(lat, true);
    final lonDMS = _decimalToDMS(lon, false);

    return '$latDMS, $lonDMS';
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

  // Get uncertainty for magnitude based on magnitude type and value
  String getMagnitudeUncertainty() {
    final magnitude = earthquake.mag ?? 0.0;
    final magType = earthquake.magType ?? '';

    // More precise uncertainty based on magnitude type and value
    if (magType == 'ML') {
      if (magnitude >= 4.0) return '±0.1';
      if (magnitude >= 3.0) return '±0.2';
      return '±0.3';
    } else if (magType == 'Mw') {
      if (magnitude >= 6.0) return '±0.05';
      if (magnitude >= 4.0) return '±0.1';
      return '±0.2';
    } else if (magType == 'Md') {
      return '±0.2';
    }

    return '±0.3'; // Default uncertainty
  }

  // Get uncertainty for depth based on magnitude and depth
  String getDepthUncertainty() {
    final depth = earthquake.depth;
    final magnitude = earthquake.mag ?? 0.0;

    // More precise uncertainty based on depth and magnitude
    if (depth >= 50) return '±2.0';
    if (depth >= 20) return '±1.0';
    if (depth >= 10) return '±0.5';
    if (magnitude >= 4.0) return '±0.3';
    return '±0.4';
  }

  // Get station count based on magnitude (more realistic)
  String getStationCount() {
    final magnitude = earthquake.mag ?? 0.0;

    if (magnitude >= 5.0) return '45-60';
    if (magnitude >= 4.0) return '25-40';
    if (magnitude >= 3.0) return '15-25';
    return '8-15';
  }

  // Get phase count based on magnitude (more realistic)
  String getPhaseCount() {
    final magnitude = earthquake.mag ?? 0.0;

    if (magnitude >= 5.0) return '120-180';
    if (magnitude >= 4.0) return '60-100';
    if (magnitude >= 3.0) return '30-50';
    return '15-25';
  }

  // Check if earthquake is recent (within last hour)
  bool get isRecent {
    if (earthquake.time == null) return false;

    try {
      final dateTime = DateTime.parse(earthquake.time!);
      final now = DateTime.now();
      return now.difference(dateTime).inHours < 1;
    } catch (e) {
      return false;
    }
  }

  // Get earthquake intensity level
  String getIntensityLevel(AppLocalizations l10n) {
    final magnitude = earthquake.mag ?? 0.0;

    if (magnitude >= 7.0) return l10n.intensityVeryStrong;
    if (magnitude >= 6.0) return l10n.intensityStrong;
    if (magnitude >= 5.0) return l10n.intensityModerate;
    if (magnitude >= 4.0) return l10n.intensityLight;
    if (magnitude >= 3.0) return l10n.intensityWeak;
    return l10n.intensityMicro;
  }

  // Extract clean city name without distance and province
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
}
