// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'W-Quake';

  @override
  String get recentEvents => 'Eventi Recenti';

  @override
  String get filteredEvents => 'Eventi Filtrati';

  @override
  String get loadingEvents => 'Caricamento eventi...';

  @override
  String get noEventsFound => 'Nessun evento trovato';

  @override
  String get filterEvents => 'Filtra eventi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get defaultFilters => 'Filtri di Default';

  @override
  String get geographicArea => 'Area Geografica';

  @override
  String get minimumMagnitude => 'Magnitudo Minima';

  @override
  String get timePeriod => 'Periodo di Tempo';

  @override
  String get lastDays => 'Ultimi giorni';

  @override
  String get customRange => 'Range personalizzato';

  @override
  String get defaultDays => 'Giorni di Default';

  @override
  String get customDateRange => 'Range di Date Personalizzato';

  @override
  String get startDate => 'Data Inizio';

  @override
  String get endDate => 'Data Fine';

  @override
  String get resetDates => 'Reset Date';

  @override
  String get saveSettings => 'Salva Impostazioni';

  @override
  String get resetToDefaults => 'Ripristina Default';

  @override
  String get apply => 'Applica';

  @override
  String get cancel => 'Annulla';

  @override
  String get defaultButton => 'Default';

  @override
  String get removeFilters => 'Rimuovi filtri';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationFilters => 'Filtri Notifiche';

  @override
  String get appLanguage => 'Lingua App';

  @override
  String get information => 'Informazioni';

  @override
  String get manageAppSettings => 'Gestisci le impostazioni dell\'applicazione';

  @override
  String get setDefaultFilters => 'Imposta i filtri predefiniti per il caricamento dei terremoti';

  @override
  String get enableNotifications => 'Abilita e gestisci le notifiche per gli eventi';

  @override
  String get customizeNotificationFilters => 'Personalizza i filtri per le notifiche degli eventi';

  @override
  String get selectAppLanguage => 'Seleziona la lingua dell\'applicazione';

  @override
  String get viewAppInfo => 'Visualizza informazioni sull\'app e le licenze';

  @override
  String get settingsSavedSuccessfully => 'Impostazioni salvate con successo';

  @override
  String get settingsResetToDefaults => 'Impostazioni ripristinate ai valori di default';

  @override
  String eventsInArea(String area) {
    return 'Eventi in $area';
  }

  @override
  String eventsInAreaLastDays(String area, int days, double magnitude) {
    return 'Eventi in $area degli ultimi $days giorni (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaLast24Hours(String area, double magnitude) {
    return 'Eventi in $area delle ultime 24 ore (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaFromDate(String area, String startDate, double magnitude) {
    return 'Eventi in $area dal $startDate (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaUntilDate(String area, String endDate, double magnitude) {
    return 'Eventi in $area fino al $endDate (mag ≥ $magnitude)';
  }

  @override
  String eventsInAreaDateRange(String area, String startDate, String endDate, double magnitude) {
    return 'Eventi in $area dal $startDate al $endDate (mag ≥ $magnitude)';
  }

  @override
  String get lastEventsInItaly => 'Ultimi eventi in Italia e zone limitrofe';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get oneDay => '1 giorno';

  @override
  String get threeDays => '3 giorni';

  @override
  String get oneWeek => '1 settimana';

  @override
  String get twoWeeks => '2 settimane';

  @override
  String get oneMonth => '1 mese';

  @override
  String get threeMonths => '3 mesi';

  @override
  String get sixMonths => '6 mesi';

  @override
  String get oneYear => '1 anno';

  @override
  String get english => 'Inglese';

  @override
  String get italian => 'Italiano';

  @override
  String get world => 'Mondo';

  @override
  String get italy => 'Italia';

  @override
  String get europe => 'Europa';

  @override
  String get asia => 'Asia';

  @override
  String get americas => 'Americhe';

  @override
  String daysAgo(int days) {
    return '$days giorni fa';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ore fa';
  }

  @override
  String hrsAgo(int hours) {
    return '$hours ore fa';
  }

  @override
  String get oneHourAgo => '1 ora fa';

  @override
  String get oneAndHalfHoursAgo => '1½ ore fa';

  @override
  String hoursAndHalfAgo(int hours) {
    return '$hours½ ore fa';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes minuti fa';
  }

  @override
  String minsAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String get now => 'Ora';

  @override
  String get justNow => 'Adesso';

  @override
  String get unknown => 'sconosciuto';

  @override
  String get invalidDate => 'Data non valida';

  @override
  String get unknownDate => 'Data sconosciuta';

  @override
  String get todaysEvents => 'Eventi di oggi';

  @override
  String get yesterdaysEvents => 'Eventi di ieri';

  @override
  String get previousDaysEvents => 'Eventi dei giorni precedenti';

  @override
  String get enablePushNotifications => 'Abilita notifiche push per eventi sismici';

  @override
  String get setMinimumMagnitudeForNotifications => 'Imposta magnitudo minima per le notifiche';

  @override
  String get minMagnitude => 'Min Magnitudo';

  @override
  String get notificationSettingsSaved => 'Impostazioni notifiche salvate';

  @override
  String get notificationArea => 'Area Notifiche';

  @override
  String get selectNotificationArea => 'Seleziona area geografica per le notifiche';

  @override
  String get appVersion => 'Versione App';

  @override
  String get developer => 'Sviluppatore';

  @override
  String get dataSource => 'Fonte Dati';

  @override
  String get credits => 'Crediti';

  @override
  String get legalInformation => 'Informazioni Legali';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Termini di Servizio';

  @override
  String get openWebsite => 'Apri Sito Web';

  @override
  String get viewDocumentation => 'Visualizza Documentazione';

  @override
  String get ingvInstitute => 'INGV (Istituto Nazionale di Geofisica e Vulcanologia)';

  @override
  String get earthquakeDataProvider => 'Fornitore Dati Sismici';

  @override
  String get openDataLicense => 'Licenza Open Data';

  @override
  String get statistics => 'Statistiche';

  @override
  String get total => 'Totale';

  @override
  String get maxMagnitude => 'Max Magnitudo';

  @override
  String get average => 'Media';

  @override
  String get version => 'Versione';

  @override
  String get build => 'Build';

  @override
  String get dataProvider => 'Fornitore Dati';

  @override
  String get license => 'Licenza';
}
