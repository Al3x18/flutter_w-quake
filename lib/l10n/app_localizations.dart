import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'W-Quake'**
  String get appTitle;

  /// Title for recent events section
  ///
  /// In en, this message translates to:
  /// **'Recent Events'**
  String get recentEvents;

  /// Title for filtered events section
  ///
  /// In en, this message translates to:
  /// **'Filtered Events'**
  String get filteredEvents;

  /// Loading message for earthquake events
  ///
  /// In en, this message translates to:
  /// **'Loading events...'**
  String get loadingEvents;

  /// Message when no events are found
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// Tooltip for filter button
  ///
  /// In en, this message translates to:
  /// **'Filter events'**
  String get filterEvents;

  /// Settings page title and button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Default filters settings title
  ///
  /// In en, this message translates to:
  /// **'Default Filters'**
  String get defaultFilters;

  /// Geographic area selection label
  ///
  /// In en, this message translates to:
  /// **'Geographic Area'**
  String get geographicArea;

  /// Minimum magnitude slider label
  ///
  /// In en, this message translates to:
  /// **'Minimum Magnitude'**
  String get minimumMagnitude;

  /// Time period selection label
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// Last days option
  ///
  /// In en, this message translates to:
  /// **'Last days'**
  String get lastDays;

  /// Custom date range option
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// Default days selection label
  ///
  /// In en, this message translates to:
  /// **'Default Days'**
  String get defaultDays;

  /// Custom date range label
  ///
  /// In en, this message translates to:
  /// **'Custom Date Range'**
  String get customDateRange;

  /// Start date picker label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End date picker label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Reset dates button
  ///
  /// In en, this message translates to:
  /// **'Reset Dates'**
  String get resetDates;

  /// Save settings button
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// Reset to defaults button
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Default button
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultButton;

  /// Remove filters button tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove filters'**
  String get removeFilters;

  /// Notifications settings title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification filters settings title
  ///
  /// In en, this message translates to:
  /// **'Notification Filters'**
  String get notificationFilters;

  /// App language settings title
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Information settings title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Settings page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage application settings'**
  String get manageAppSettings;

  /// Default filters card subtitle
  ///
  /// In en, this message translates to:
  /// **'Set default filters for loading earthquakes'**
  String get setDefaultFilters;

  /// Notifications card subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable and manage event notifications'**
  String get enableNotifications;

  /// Notification filters card subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize notification filters for events'**
  String get customizeNotificationFilters;

  /// App language card subtitle
  ///
  /// In en, this message translates to:
  /// **'Select application language'**
  String get selectAppLanguage;

  /// Information card subtitle
  ///
  /// In en, this message translates to:
  /// **'View app version, credits and legal information'**
  String get viewAppInfo;

  /// Success message when settings are saved
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// Success message when settings are reset
  ///
  /// In en, this message translates to:
  /// **'Settings reset to default values'**
  String get settingsResetToDefaults;

  /// Events in specific area
  ///
  /// In en, this message translates to:
  /// **'Events in {area}'**
  String eventsInArea(String area);

  /// Events in area for last days
  ///
  /// In en, this message translates to:
  /// **'Events in {area} of the last {days} days (mag ≥ {magnitude})'**
  String eventsInAreaLastDays(String area, int days, double magnitude);

  /// Events in area for last 24 hours
  ///
  /// In en, this message translates to:
  /// **'Events in {area} of the last 24 hours (mag ≥ {magnitude})'**
  String eventsInAreaLast24Hours(String area, double magnitude);

  /// Events in area from specific date
  ///
  /// In en, this message translates to:
  /// **'Events in {area} from {startDate} (mag ≥ {magnitude})'**
  String eventsInAreaFromDate(String area, String startDate, double magnitude);

  /// Events in area until specific date
  ///
  /// In en, this message translates to:
  /// **'Events in {area} until {endDate} (mag ≥ {magnitude})'**
  String eventsInAreaUntilDate(String area, String endDate, double magnitude);

  /// Events in area for date range
  ///
  /// In en, this message translates to:
  /// **'Events in {area} from {startDate} to {endDate} (mag ≥ {magnitude})'**
  String eventsInAreaDateRange(String area, String startDate, String endDate, double magnitude);

  /// Default description for Italy events
  ///
  /// In en, this message translates to:
  /// **'Last events in Italy and surrounding areas'**
  String get lastEventsInItaly;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// One day option
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// Three days option
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get threeDays;

  /// One week option
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get oneWeek;

  /// Two weeks option
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get twoWeeks;

  /// One month option
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get oneMonth;

  /// Three months option
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get threeMonths;

  /// Six months option
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get sixMonths;

  /// One year option
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get oneYear;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// World geographic area
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get world;

  /// Italy geographic area
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get italy;

  /// Europe geographic area
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get europe;

  /// Asia geographic area
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get asia;

  /// Americas geographic area
  ///
  /// In en, this message translates to:
  /// **'Americas'**
  String get americas;

  /// Time elapsed in days
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Time elapsed in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// Time elapsed in hours (short)
  ///
  /// In en, this message translates to:
  /// **'{hours} hrs ago'**
  String hrsAgo(int hours);

  /// One hour ago
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get oneHourAgo;

  /// One and a half hours ago
  ///
  /// In en, this message translates to:
  /// **'1½ hours ago'**
  String get oneAndHalfHoursAgo;

  /// Hours and a half ago
  ///
  /// In en, this message translates to:
  /// **'{hours}½ hours ago'**
  String hoursAndHalfAgo(int hours);

  /// Time elapsed in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// Time elapsed in minutes (short)
  ///
  /// In en, this message translates to:
  /// **'{minutes} mins ago'**
  String minsAgo(int minutes);

  /// Current moment
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Very recent time
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Unknown value
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// Error message for invalid date
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// Message when date is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// Section header for today's events
  ///
  /// In en, this message translates to:
  /// **'Today\'s events'**
  String get todaysEvents;

  /// Section header for yesterday's events
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s events'**
  String get yesterdaysEvents;

  /// Section header for events from previous days
  ///
  /// In en, this message translates to:
  /// **'Previous days events'**
  String get previousDaysEvents;

  /// Description for enabling push notifications
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications for earthquake events'**
  String get enablePushNotifications;

  /// Description for setting minimum magnitude for notifications
  ///
  /// In en, this message translates to:
  /// **'Set minimum magnitude for notifications'**
  String get setMinimumMagnitudeForNotifications;

  /// Label for minimum magnitude slider
  ///
  /// In en, this message translates to:
  /// **'Min Magnitude'**
  String get minMagnitude;

  /// Success message when notification settings are saved
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved'**
  String get notificationSettingsSaved;

  /// Label for notification area selection
  ///
  /// In en, this message translates to:
  /// **'Notification Area'**
  String get notificationArea;

  /// Description for selecting notification area
  ///
  /// In en, this message translates to:
  /// **'Select geographic area for notifications'**
  String get selectNotificationArea;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Label for developer information
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Label for data source information
  ///
  /// In en, this message translates to:
  /// **'Data Source'**
  String get dataSource;

  /// Label for credits section
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// Label for legal information section
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInformation;

  /// Label for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Label for terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Button text to open website
  ///
  /// In en, this message translates to:
  /// **'Open Website'**
  String get openWebsite;

  /// Button text to view documentation
  ///
  /// In en, this message translates to:
  /// **'View Documentation'**
  String get viewDocumentation;

  /// Full name of INGV institute
  ///
  /// In en, this message translates to:
  /// **'INGV (Istituto Nazionale di Geofisica e Vulcanologia)'**
  String get ingvInstitute;

  /// Description for earthquake data provider
  ///
  /// In en, this message translates to:
  /// **'Earthquake Data Provider'**
  String get earthquakeDataProvider;

  /// Description for data license
  ///
  /// In en, this message translates to:
  /// **'Open Data License'**
  String get openDataLicense;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Total events label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Maximum magnitude label
  ///
  /// In en, this message translates to:
  /// **'Max Magnitude'**
  String get maxMagnitude;

  /// Average magnitude label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Build number label
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// Data provider label
  ///
  /// In en, this message translates to:
  /// **'Data Provider'**
  String get dataProvider;

  /// License label
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// Strong magnitude description
  ///
  /// In en, this message translates to:
  /// **'strong'**
  String get magnitudeStrong;

  /// Moderate magnitude description
  ///
  /// In en, this message translates to:
  /// **'moderate'**
  String get magnitudeModerate;

  /// Light magnitude description
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get magnitudeLight;

  /// Minor magnitude description
  ///
  /// In en, this message translates to:
  /// **'minor'**
  String get magnitudeMinor;

  /// Micro magnitude description
  ///
  /// In en, this message translates to:
  /// **'micro'**
  String get magnitudeMicro;

  /// Deep depth description
  ///
  /// In en, this message translates to:
  /// **'deep'**
  String get depthDeep;

  /// Intermediate depth description
  ///
  /// In en, this message translates to:
  /// **'intermediate'**
  String get depthIntermediate;

  /// Shallow depth description
  ///
  /// In en, this message translates to:
  /// **'shallow'**
  String get depthShallow;

  /// Very strong intensity description
  ///
  /// In en, this message translates to:
  /// **'very strong'**
  String get intensityVeryStrong;

  /// Strong intensity description
  ///
  /// In en, this message translates to:
  /// **'strong'**
  String get intensityStrong;

  /// Moderate intensity description
  ///
  /// In en, this message translates to:
  /// **'moderate'**
  String get intensityModerate;

  /// Light intensity description
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get intensityLight;

  /// Weak intensity description
  ///
  /// In en, this message translates to:
  /// **'weak'**
  String get intensityWeak;

  /// Micro intensity description
  ///
  /// In en, this message translates to:
  /// **'micro'**
  String get intensityMicro;

  /// Magnitude section title
  ///
  /// In en, this message translates to:
  /// **'Magnitude'**
  String get magnitude;

  /// Technical details section title
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get technicalDetails;

  /// Coordinates section title
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// Description section title
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Event ID label
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get eventId;

  /// Origin ID label
  ///
  /// In en, this message translates to:
  /// **'Origin ID'**
  String get originId;

  /// Author label
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Review status label
  ///
  /// In en, this message translates to:
  /// **'Review Status'**
  String get reviewStatus;

  /// Stations label
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// Phases label
  ///
  /// In en, this message translates to:
  /// **'Phases'**
  String get phases;

  /// Decimal degrees format label
  ///
  /// In en, this message translates to:
  /// **'Decimal Degrees'**
  String get decimalDegrees;

  /// DMS format label
  ///
  /// In en, this message translates to:
  /// **'DMS Format'**
  String get dmsFormat;

  /// Precise decimal label
  ///
  /// In en, this message translates to:
  /// **'Precise Decimal'**
  String get preciseDecimal;

  /// Depth label
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depth;

  /// Intensity level label
  ///
  /// In en, this message translates to:
  /// **'Intensity Level'**
  String get intensityLevel;

  /// Unknown location fallback text
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// Location permission title
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// Location permission description
  ///
  /// In en, this message translates to:
  /// **'This app needs access to location to show your position on the earthquake map.'**
  String get locationPermissionDescription;

  /// Enable location button text
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// Location services disabled title
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get locationDisabled;

  /// Location services disabled description
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Enable them in settings to see your position on the map.'**
  String get locationDisabledDescription;

  /// Location permission denied title
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// Location permission denied description
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Enable it to see your position on the map.'**
  String get locationPermissionDeniedDescription;

  /// Location permission permanently denied title
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionPermanentlyDenied;

  /// Location permission permanently denied description
  ///
  /// In en, this message translates to:
  /// **'Location permission was permanently denied. Enable it in app settings.'**
  String get locationPermissionPermanentlyDeniedDescription;

  /// Unable to get location title
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;

  /// Unable to get location description
  ///
  /// In en, this message translates to:
  /// **'An error occurred while retrieving location. Please try again later.'**
  String get unableToGetLocationDescription;

  /// Your location label
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// Distance from you label
  ///
  /// In en, this message translates to:
  /// **'Distance from you'**
  String get distanceFromYou;

  /// Show my location button text
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get showMyLocation;

  /// Hide my location button text
  ///
  /// In en, this message translates to:
  /// **'Hide my location'**
  String get hideMyLocation;

  /// Center on my location button text
  ///
  /// In en, this message translates to:
  /// **'Center on my location'**
  String get centerOnMyLocation;

  /// Location permission required title
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// Location permission required message
  ///
  /// In en, this message translates to:
  /// **'To center on your location, grant permission in settings'**
  String get locationPermissionRequiredMessage;

  /// Earthquake description with magnitude and classification
  ///
  /// In en, this message translates to:
  /// **'This earthquake has a magnitude of {magnitude} {magType}, which is classified as {magnitudeDescription}.'**
  String earthquakeDescription(String magnitude, String magType, String magnitudeDescription);

  /// One day ago
  ///
  /// In en, this message translates to:
  /// **'day ago'**
  String get dayAgo;

  /// One minute ago
  ///
  /// In en, this message translates to:
  /// **'minute ago'**
  String get minuteAgo;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
