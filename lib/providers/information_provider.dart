import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationState {
  final String appVersion;
  final String versionOnly;
  final String buildNumber;
  final String packageName;
  final String appName;
  final String appDescription;
  final String developerName;

  const InformationState({
    this.appVersion = 'Unknown',
    this.versionOnly = 'Unknown',
    this.buildNumber = 'Unknown',
    this.packageName = 'Unknown',
    this.appName = 'W-Quake',
    this.appDescription = 'Real-time earthquake monitoring app',
    this.developerName = 'Alex De Pasquale',
  });

  InformationState copyWith({
    String? appVersion,
    String? versionOnly,
    String? buildNumber,
    String? packageName,
    String? appName,
    String? appDescription,
    String? developerName,
  }) {
    return InformationState(
      appVersion: appVersion ?? this.appVersion,
      versionOnly: versionOnly ?? this.versionOnly,
      buildNumber: buildNumber ?? this.buildNumber,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appDescription: appDescription ?? this.appDescription,
      developerName: developerName ?? this.developerName,
    );
  }
}

class InformationNotifier extends AsyncNotifier<InformationState> {
  // Static configuration
  static const String _appName = 'W-Quake';
  static const String _appDescription = 'Real-time earthquake monitoring app';
  static const String _developerName = 'Alex De Pasquale';
  static const String _appWebsite = 'https://github.com/Al3x18/flutter_w-quake';
  static const String _privacyPolicyUrl = '';
  static const String _termsOfServiceUrl = '';
  static const String _ingvApiUrl = 'https://webservices.ingv.it/';
  static const String _ingvWebsite = 'https://www.ingv.it/';
  static const String _usgsApiUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/';
  static const String _usgsWebsite = 'https://www.usgs.gov/';

  @override
  Future<InformationState> build() async {
    return _loadAppInformation();
  }

  Future<InformationState> _loadAppInformation() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      return InformationState(
        appVersion: '${packageInfo.version} (${packageInfo.buildNumber})',
        versionOnly: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        packageName: packageInfo.packageName,
        appName: packageInfo.appName.isEmpty ? _appName : packageInfo.appName,
        appDescription: _appDescription,
        developerName: _developerName,
      );
    } catch (e) {
      debugPrint('[InformationNotifier] Error loading app info: $e');
      return const InformationState();
    }
  }

  // --- External Actions ---

  Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[InformationNotifier] Error launching URL: $e');
      return false;
    }
  }

  Future<bool> launchAppWebsite() => _launchUrl(_appWebsite);
  Future<bool> launchPrivacyPolicy() => _launchUrl(_privacyPolicyUrl);
  Future<bool> launchTermsOfService() => _launchUrl(_termsOfServiceUrl);
  Future<bool> launchIngvWebsite() => _launchUrl(_ingvWebsite);
  Future<bool> launchIngvApiDocumentation() => _launchUrl(_ingvApiUrl);
  Future<bool> launchUsgsWebsite() => _launchUrl(_usgsWebsite);
  Future<bool> launchUsgsApiDocumentation() => _launchUrl(_usgsApiUrl);

  // --- Getters for static info ---

  String getAppWebsite() => _appWebsite;
  String getPrivacyPolicyUrl() => _privacyPolicyUrl;
  String getTermsOfServiceUrl() => _termsOfServiceUrl;
  String getIngvWebsite() => _ingvWebsite;
  String getIngvApiUrl() => _ingvApiUrl;

  Map<String, String> getCredits() => {
        'data_source': 'INGV (Istituto Nazionale di Geofisica e Vulcanologia)',
        'api_url': _ingvApiUrl,
        'ingv_website': _ingvWebsite,
        'developer': _developerName,
        'app_website': _appWebsite,
      };

  Map<String, String> getLegalInfo() => {
        'privacy_policy': _privacyPolicyUrl,
        'terms_of_service': _termsOfServiceUrl,
        'data_source': 'INGV Web Services API',
        'data_license': 'Open Data License',
      };
}

final informationProvider =
    AsyncNotifierProvider<InformationNotifier, InformationState>(
      InformationNotifier.new,
    );
