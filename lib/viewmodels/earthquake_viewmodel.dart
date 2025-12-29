import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import '../models/earthquake_filter.dart';
import '../models/earthquake_source.dart';
import '../services/earthquake_api_service.dart';

class EarthquakeViewModel {
  final EarthquakeApiService _apiService;

  EarthquakeViewModel({EarthquakeApiService? apiService})
    : _apiService = apiService ?? EarthquakeApiService();

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

	/// This code is weird i know but it works for now i guess, need some changes in future definitely :)
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
    if (place.contains('Central African Republic')) {
      return 'Central African Republic';
    }
    if (place.contains('Congo Democratic Republic')) {
      return 'Congo Democratic Republic';
    }
    if (place.contains('Congo')) return 'Congo';
    if (place.contains('Gabon')) return 'Gabon';
    if (place.contains('Equatorial Guinea')) return 'Equatorial Guinea';
    if (place.contains('Sao Tome and Principe')) return 'Sao Tome and Principe';
    if (place.contains('Benin')) return 'Benin';
    if (place.contains('Burkina Faso')) return 'Burkina Faso';
    if (place.contains('Mali')) return 'Mali';
    if (place.contains('Senegal')) return 'Senegal';
    if (place.contains('Gambia')) return 'Gambia';
    if (place.contains('Guinea-Bissau')) return 'Guinea-Bissau';
    if (place.contains('Guinea')) return 'Guinea';
    if (place.contains('Liberia')) return 'Liberia';
    if (place.contains('Sierra Leone')) return 'Sierra Leone';
    if (place.contains('Ivory Coast')) return 'Ivory Coast';
    if (place.contains('Ghana')) return 'Ghana';
    if (place.contains('Togo')) return 'Togo';
    debugPrint('[EarthquakeViewModel] Unknown region: $place');
    return 'Other regions';
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