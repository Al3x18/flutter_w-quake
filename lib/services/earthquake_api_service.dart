import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/earthquake.dart';
import '../models/earthquake_source.dart';

class EarthquakeApiService {
  void _log(String message) {
    debugPrint('[EarthquakeApiService] $message');
  }

  void _logError(String message, dynamic error) {
    debugPrint('[EarthquakeApiService ERROR] $message: $error');
  }

  Future<EarthquakeResponse> getEarthquakes({
    String? startTime,
    String? endTime,
    double? minMagnitude,
    double? minLatitude,
    double? maxLatitude,
    double? minLongitude,
    double? maxLongitude,
    EarthquakeSource source = EarthquakeSource.ingv,
  }) async {
    final baseUrl = source.apiBaseUrl;

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'format': 'geojson',
        'orderby': 'time',
        if (startTime != null) 'starttime': startTime,
        if (endTime != null) 'endtime': endTime,
        if (minMagnitude != null) 'minmagnitude': minMagnitude.toString(),
        if (minLatitude != null) 'minlatitude': minLatitude.toString(),
        if (maxLatitude != null) 'maxlatitude': maxLatitude.toString(),
        if (minLongitude != null) 'minlongitude': minLongitude.toString(),
        if (maxLongitude != null) 'maxlongitude': maxLongitude.toString(),
      },
    );

    _log('Requesting earthquakes from ${source.name}: $uri');

    try {
      final response = await http.get(uri);
      _log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final featuresCount = jsonData['features']?.length ?? 0;
        _log('Successfully parsed JSON with $featuresCount features');
        return EarthquakeResponse.fromJson(jsonData);
      } else if (response.statusCode == 204) {
        _log('No content - no earthquakes found in the specified range');

        return EarthquakeResponse(type: 'FeatureCollection', features: []);
      } else if (response.statusCode == 413) {
        _logError(
          'Too many events in request',
          'Status: 413, Body: ${response.body}',
        );
        throw Exception(
          'Troppi eventi nel periodo selezionato. Riduci il range di date o aumenta la magnitudo minima.',
        );
      } else if (response.statusCode == 400) {
        _logError('Bad request', 'Status: 400, Body: ${response.body}');
        throw Exception(
          'Parametri di ricerca non validi. Controlla le date e i filtri selezionati.',
        );
      } else if (response.statusCode == 500) {
        _logError('Server error', 'Status: 500, Body: ${response.body}');
        throw Exception('Errore del server. Riprova più tardi.');
      } else if (response.statusCode == 503) {
        _logError('Service unavailable', 'Status: 503, Body: ${response.body}');
        throw Exception(
          'Servizio temporaneamente non disponibile. Riprova più tardi.',
        );
      } else {
        _logError(
          'Unexpected status code',
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Errore di connessione. Verifica la tua connessione internet e riprova.',
        );
      }
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception:')) {
        rethrow;
      }

      _logError('Network or parsing error', e);

      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception(
          'Errore di connessione. Verifica la tua connessione internet e riprova.',
        );
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('TypeError')) {
        throw Exception(
          'Errore nel formato dei dati ricevuti. Riprova più tardi.',
        );
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout della connessione. Riprova più tardi.');
      } else {
        throw Exception('Errore imprevisto. Riprova più tardi.');
      }
    }
  }
}
