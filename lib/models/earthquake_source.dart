enum EarthquakeSource {
  ingv,
  usgs;

  String get displayName {
    switch (this) {
      case EarthquakeSource.ingv:
        return 'INGV (Italy)';
      case EarthquakeSource.usgs:
        return 'USGS (World)';
    }
  }

  String get apiBaseUrl {
    switch (this) {
      case EarthquakeSource.ingv:
        return 'https://webservices.ingv.it/fdsnws/event/1/query';
      case EarthquakeSource.usgs:
        return 'https://earthquake.usgs.gov/fdsnws/event/1/query';
    }
  }
}
