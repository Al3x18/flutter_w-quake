import 'package:intl/intl.dart';
import '../models/earthquake.dart';
import '../l10n/app_localizations.dart';

class EarthquakeDetailViewModel {
  final Earthquake earthquake;

  EarthquakeDetailViewModel({required this.earthquake});

  String formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

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

  String getMagnitudeDescription(double magnitude, AppLocalizations l10n) {
    if (magnitude >= 6.0) return l10n.magnitudeStrong;
    if (magnitude >= 5.0) return l10n.magnitudeModerate;
    if (magnitude >= 4.0) return l10n.magnitudeLight;
    if (magnitude >= 3.0) return l10n.magnitudeMinor;
    return l10n.magnitudeMicro;
  }

  String getDepthDescription(double depth, AppLocalizations l10n) {
    if (depth >= 70) return l10n.depthDeep;
    if (depth >= 30) return l10n.depthIntermediate;
    return l10n.depthShallow;
  }

  String formatCoordinates() {
    final lat = earthquake.latitude;
    final lon = earthquake.longitude;

    final latStr = lat >= 0
        ? '${lat.toStringAsFixed(4)}°N'
        : '${(-lat).toStringAsFixed(4)}°S';
    final lonStr = lon >= 0
        ? '${lon.toStringAsFixed(4)}°E'
        : '${(-lon).toStringAsFixed(4)}°W';

    return '$latStr, $lonStr';
  }

  String formatCoordinatesDecimal() {
    return '${earthquake.latitude.toStringAsFixed(6)}, ${earthquake.longitude.toStringAsFixed(6)}';
  }

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

    final direction = isLatitude
        ? (decimal >= 0 ? 'N' : 'S')
        : (decimal >= 0 ? 'E' : 'W');

    return '$degrees°$minutes\'${seconds.toStringAsFixed(1)}"$direction';
  }

  String getMagnitudeUncertainty() {
    return '';
  }

  String getDepthUncertainty() {
    return '';
  }

  String? getStationCount() {
    return null;
  }

  String? getPhaseCount() {
    return null;
  }

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

  String getIntensityLevel(AppLocalizations l10n) {
    final magnitude = earthquake.mag ?? 0.0;

    if (magnitude >= 7.0) return l10n.intensityVeryStrong;
    if (magnitude >= 6.0) return l10n.intensityStrong;
    if (magnitude >= 5.0) return l10n.intensityModerate;
    if (magnitude >= 4.0) return l10n.intensityLight;
    if (magnitude >= 3.0) return l10n.intensityWeak;
    return l10n.intensityMicro;
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
}
