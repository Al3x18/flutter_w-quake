// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'W-Quake';

  @override
  String get recentEvents => 'Recent Events';

  @override
  String get filteredEvents => 'Filtered Events';

  @override
  String get loadingEvents => 'Loading events...';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get filterEvents => 'Filter events';

  @override
  String get settings => 'Settings';

  @override
  String get defaultFilters => 'Default Filters';

  @override
  String get geographicArea => 'Geographic Area';

  @override
  String get minimumMagnitude => 'Minimum Magnitude';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get lastDays => 'Last days';

  @override
  String get customRange => 'Custom range';

  @override
  String get defaultDays => 'Default Days';

  @override
  String get customDateRange => 'Custom Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get resetDates => 'Reset Dates';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get defaultButton => 'Default';

  @override
  String get removeFilters => 'Remove filters';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationFilters => 'Notification Filters';

  @override
  String get appLanguage => 'App Language';

  @override
  String get information => 'Information';

  @override
  String get manageAppSettings => 'Manage application settings';

  @override
  String get setDefaultFilters => 'Set default filters for loading earthquakes';

  @override
  String get enableNotifications => 'Enable and manage event notifications';

  @override
  String get customizeNotificationFilters =>
      'Customize notification filters for events';

  @override
  String get selectAppLanguage => 'Select application language';

  @override
  String get viewAppInfo => 'View app version, credits and legal information';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

  @override
  String get settingsResetToDefaults => 'Settings reset to default values';

  @override
  String eventsInArea(String area) {
    return 'Events in $area';
  }

  @override
  String eventsInAreaLastDays(String area, int days, double magnitude) {
    return 'Events in $area of the last $days days (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaLast24Hours(String area, double magnitude) {
    return 'Events in $area of the last 24 hours (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaFromDate(String area, String startDate, double magnitude) {
    return 'Events in $area from $startDate (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaUntilDate(String area, String endDate, double magnitude) {
    return 'Events in $area until $endDate (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaDateRange(
    String area,
    String startDate,
    String endDate,
    double magnitude,
  ) {
    return 'Events in $area from $startDate to $endDate (mag ≥ $magnitude)';
  }

  @override
  String get lastEventsInItaly => 'Last events in Italy and surrounding areas';

  @override
  String get selectDate => 'Select date';

  @override
  String get oneDay => '1 day';

  @override
  String get threeDays => '3 days';

  @override
  String get oneWeek => '1 week';

  @override
  String get twoWeeks => '2 weeks';

  @override
  String get oneMonth => '1 month';

  @override
  String get threeMonths => '3 months';

  @override
  String get sixMonths => '6 months';

  @override
  String get oneYear => '1 year';

  @override
  String get english => 'English';

  @override
  String get italian => 'Italian';

  @override
  String get world => 'World';

  @override
  String get italy => 'Italy';

  @override
  String get europe => 'Europe';

  @override
  String get asia => 'Asia';

  @override
  String get americas => 'Americas';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String hrsAgo(int hours) {
    return '$hours hrs ago';
  }

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get oneAndHalfHoursAgo => '1½ hours ago';

  @override
  String hoursAndHalfAgo(int hours) {
    return '$hours½ hours ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String minsAgo(int minutes) {
    return '$minutes mins ago';
  }

  @override
  String get now => 'Now';

  @override
  String get justNow => 'Just now';

  @override
  String get unknown => 'unknown';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get todaysEvents => 'Today\'s events';

  @override
  String get yesterdaysEvents => 'Yesterday\'s events';

  @override
  String get previousDaysEvents => 'Previous days events';

  @override
  String get enablePushNotifications =>
      'Enable push notifications for earthquake events';

  @override
  String get setMinimumMagnitudeForNotifications =>
      'Set minimum magnitude for notifications';

  @override
  String get minMagnitude => 'Min Magnitude';

  @override
  String get notificationSettingsSaved => 'Notification settings saved';

  @override
  String get notificationArea => 'Notification Area';

  @override
  String get selectNotificationArea =>
      'Select geographic area for notifications';

  @override
  String get appVersion => 'App Version';

  @override
  String get developer => 'Developer';

  @override
  String get dataSource => 'Data Source';

  @override
  String get credits => 'Credits';

  @override
  String get legalInformation => 'Legal Information';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openWebsite => 'Open Website';

  @override
  String get viewDocumentation => 'View Documentation';

  @override
  String get ingvInstitute =>
      'INGV (Istituto Nazionale di Geofisica e Vulcanologia)';

  @override
  String get earthquakeDataProvider => 'Earthquake Data Provider';

  @override
  String get openDataLicense => 'Open Data License';

  @override
  String get statistics => 'Statistics';

  @override
  String get total => 'Total';

  @override
  String get maxMagnitude => 'Max Magnitude';

  @override
  String get average => 'Average';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get dataProvider => 'Data Provider';

  @override
  String get license => 'License';

  @override
  String get magnitudeStrong => 'strong';

  @override
  String get magnitudeModerate => 'moderate';

  @override
  String get magnitudeLight => 'light';

  @override
  String get magnitudeMinor => 'minor';

  @override
  String get magnitudeMicro => 'micro';

  @override
  String get depthDeep => 'deep';

  @override
  String get depthIntermediate => 'intermediate';

  @override
  String get depthShallow => 'shallow';

  @override
  String get intensityVeryStrong => 'very strong';

  @override
  String get intensityStrong => 'strong';

  @override
  String get intensityModerate => 'moderate';

  @override
  String get intensityLight => 'light';

  @override
  String get intensityWeak => 'weak';

  @override
  String get intensityMicro => 'micro';

  @override
  String get magnitude => 'Magnitude';

  @override
  String get technicalDetails => 'Technical Details';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get description => 'Description';

  @override
  String get eventId => 'Event ID';

  @override
  String get originId => 'Origin ID';

  @override
  String get author => 'Author';

  @override
  String get type => 'Type';

  @override
  String get reviewStatus => 'Review Status';

  @override
  String get stations => 'Stations';

  @override
  String get phases => 'Phases';

  @override
  String get decimalDegrees => 'Decimal Degrees';

  @override
  String get dmsFormat => 'DMS Format';

  @override
  String get preciseDecimal => 'Precise Decimal';

  @override
  String get depth => 'Depth';

  @override
  String get intensityLevel => 'Intensity Level';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get locationPermission => 'Location Permission';

  @override
  String get locationPermissionDescription =>
      'This app needs access to location to show your position on the earthquake map.';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get goToLocationSettings => 'Go to Location Settings';

  @override
  String get locationCanBeEnabledLater => 'Location can be enabled later in settings';

  @override
  String get allowLocationAccess => 'Allow app to access your location';

  @override
  String get showLocationOnMap => 'Show your location on the earthquake map';

  @override
  String get locationDisabled => 'Location services disabled';

  @override
  String get locationDisabledDescription =>
      'Location services are disabled. Enable them in settings to see your position on the map.';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationPermissionDeniedDescription =>
      'Location permission was denied. Enable it to see your position on the map.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission permanently denied';

  @override
  String get locationPermissionPermanentlyDeniedDescription =>
      'Location permission was permanently denied. Enable it in app settings.';

  @override
  String get unableToGetLocation => 'Unable to get location';

  @override
  String get unableToGetLocationDescription =>
      'An error occurred while retrieving location. Please try again later.';

  @override
  String get yourLocation => 'Your location';

  @override
  String get distanceFromYou => 'Distance from you';

  @override
  String get showMyLocation => 'Show my location';

  @override
  String get hideMyLocation => 'Hide my location';

  @override
  String get centerOnMyLocation => 'Center on my location';

  @override
  String get locationAccessGranted => 'Location access granted';

  @override
  String get requestingLocationAccess => 'Requesting location access...';

  @override
  String get locationAccessDenied => 'Location access denied';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get enableLocationPermissionsManually =>
      'Manually enable location permissions';

  @override
  String get locationEnabledSuccess =>
      'Location enabled! Your position will be shown on the map.';

  @override
  String get searchRadius => 'Search radius';

  @override
  String get searchRadiusSubtitle => 'Indicate events around my position';

  @override
  String get nearYou => 'Near you';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get locationPermissionRequiredMessage =>
      'To center on your location, grant permission in settings';

  @override
  String earthquakeDescription(
    String magnitude,
    String magType,
    String magnitudeDescription,
  ) {
    return 'This earthquake has a magnitude of $magnitude $magType, which is classified as $magnitudeDescription.';
  }

  @override
  String get dayAgo => 'day ago';

  @override
  String get minuteAgo => 'minute ago';

  @override
  String get nearbyIndicatorDescription =>
      'Events within your selected radius are marked with an orange indicator';

  @override
  String get selectDataSourceDescription =>
      'Select the provider for earthquake data';

  @override
  String get sourceIngv => 'INGV (Italy)';

  @override
  String get sourceUsgs => 'USGS (World)';

  @override
  String errorSavingSettings(String error) {
    return 'Failed to save settings: $error';
  }

  @override
  String get openSourceCode => 'This application is Open Source.';

  @override
  String get viewSourceCode => 'View Source Code';

  @override
  String get developerWebsite => 'Developer Website';
}
