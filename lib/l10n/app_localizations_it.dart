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
  String get minMagnitude => 'Magnitudo Min';

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
  String get maxMagnitude => 'Magnitudo Max';

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

  @override
  String get magnitudeStrong => 'forte';

  @override
  String get magnitudeModerate => 'moderato';

  @override
  String get magnitudeLight => 'leggero';

  @override
  String get magnitudeMinor => 'minore';

  @override
  String get magnitudeMicro => 'micro';

  @override
  String get depthDeep => 'profondo';

  @override
  String get depthIntermediate => 'intermedio';

  @override
  String get depthShallow => 'superficiale';

  @override
  String get intensityVeryStrong => 'molto forte';

  @override
  String get intensityStrong => 'forte';

  @override
  String get intensityModerate => 'moderato';

  @override
  String get intensityLight => 'leggero';

  @override
  String get intensityWeak => 'debole';

  @override
  String get intensityMicro => 'micro';

  @override
  String get magnitude => 'Magnitudo';

  @override
  String get technicalDetails => 'Dettagli Tecnici';

  @override
  String get coordinates => 'Coordinate';

  @override
  String get description => 'Descrizione';

  @override
  String get eventId => 'ID Evento';

  @override
  String get originId => 'ID Origine';

  @override
  String get author => 'Autore';

  @override
  String get type => 'Tipo';

  @override
  String get reviewStatus => 'Stato Revisione';

  @override
  String get stations => 'Stazioni';

  @override
  String get phases => 'Fasi';

  @override
  String get decimalDegrees => 'Gradi Decimali';

  @override
  String get dmsFormat => 'Formato DMS';

  @override
  String get preciseDecimal => 'Decimale Preciso';

  @override
  String get depth => 'Profondità';

  @override
  String get intensityLevel => 'Livello Intensità';

  @override
  String get unknownLocation => 'Posizione Sconosciuta';

  @override
  String get locationPermission => 'Permessi di Posizione';

  @override
  String get locationPermissionDescription => 'Questa app ha bisogno dell\'accesso alla posizione per mostrare la tua posizione sulla mappa dei terremoti.';

  @override
  String get enableLocation => 'Abilita Posizione';

  @override
  String get locationDisabled => 'Servizi di posizione disabilitati';

  @override
  String get locationDisabledDescription => 'I servizi di posizione sono disabilitati. Abilitali nelle impostazioni per vedere la tua posizione sulla mappa.';

  @override
  String get locationPermissionDenied => 'Permesso di posizione negato';

  @override
  String get locationPermissionDeniedDescription => 'Il permesso di posizione è stato negato. Abilitalo per vedere la tua posizione sulla mappa.';

  @override
  String get locationPermissionPermanentlyDenied => 'Permesso di posizione negato permanentemente';

  @override
  String get locationPermissionPermanentlyDeniedDescription => 'Il permesso di posizione è stato negato permanentemente. Abilitalo nelle impostazioni dell\'app.';

  @override
  String get unableToGetLocation => 'Impossibile ottenere la posizione';

  @override
  String get unableToGetLocationDescription => 'Si è verificato un errore nel recupero della posizione. Riprova più tardi.';

  @override
  String get yourLocation => 'La tua posizione';

  @override
  String get distanceFromYou => 'Distanza da te';

  @override
  String get showMyLocation => 'Mostra la mia posizione';

  @override
  String get hideMyLocation => 'Nascondi la mia posizione';

  @override
  String get centerOnMyLocation => 'Centra sulla mia posizione';

  @override
  String get locationPermissionRequired => 'Autorizzazione posizione richiesta';

  @override
  String get locationPermissionRequiredMessage => 'Per centrare sulla tua posizione, concedi l\'autorizzazione nelle impostazioni';

  @override
  String earthquakeDescription(String magnitude, String magType, String magnitudeDescription) {
    return 'Questo terremoto ha una magnitudo di $magnitude $magType, che è classificata come $magnitudeDescription.';
  }

  @override
  String get dayAgo => 'giorno fa';

  @override
  String get minuteAgo => 'minuto fa';
}
