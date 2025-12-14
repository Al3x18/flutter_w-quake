import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationService {
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

  Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('[InformationService] Error getting package info: $e');
      rethrow;
    }
  }

  Future<String> getAppVersion() async {
    try {
      final packageInfo = await getPackageInfo();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      debugPrint('[InformationService] Error getting app version: $e');
      return 'Unknown';
    }
  }

  Future<String> getVersionOnly() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.version;
    } catch (e) {
      debugPrint('[InformationService] Error getting version: $e');
      return 'Unknown';
    }
  }

  Future<String> getBuildNumber() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.buildNumber;
    } catch (e) {
      debugPrint('[InformationService] Error getting build number: $e');
      return 'Unknown';
    }
  }

  Future<String> getPackageName() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.packageName;
    } catch (e) {
      debugPrint('[InformationService] Error getting package name: $e');
      return 'Unknown';
    }
  }

  Future<String> getAppNameFromPackage() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.appName;
    } catch (e) {
      debugPrint(
        '[InformationService] Error getting app name from package: $e',
      );
      return _appName;
    }
  }

  String getAppName() => _appName;

  String getAppDescription() => _appDescription;

  String getDeveloperName() => _developerName;

  String getAppWebsite() => _appWebsite;

  String getPrivacyPolicyUrl() => _privacyPolicyUrl;

  String getTermsOfServiceUrl() => _termsOfServiceUrl;

  String getIngvApiUrl() => _ingvApiUrl;

  String getIngvWebsite() => _ingvWebsite;

  String getUsgsApiUrl() => _usgsApiUrl;

  String getUsgsWebsite() => _usgsWebsite;

  Future<bool> launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        debugPrint('[InformationService] Launched URL: $url');
        return true;
      } else {
        debugPrint('[InformationService] Cannot launch URL: $url');
        return false;
      }
    } catch (e) {
      debugPrint('[InformationService] Error launching URL: $e');
      return false;
    }
  }

  Future<bool> launchAppWebsite() async {
    return await launchExternalUrl(_appWebsite);
  }

  Future<bool> launchPrivacyPolicy() async {
    return await launchExternalUrl(_privacyPolicyUrl);
  }

  Future<bool> launchTermsOfService() async {
    return await launchExternalUrl(_termsOfServiceUrl);
  }

  Future<bool> launchIngvWebsite() async {
    return await launchExternalUrl(_ingvWebsite);
  }

  Future<bool> launchIngvApiDocumentation() async {
    return await launchExternalUrl(_ingvApiUrl);
  }

  Future<bool> launchUsgsWebsite() async {
    return await launchExternalUrl(_usgsWebsite);
  }

  Future<bool> launchUsgsApiDocumentation() async {
    return await launchExternalUrl(_usgsApiUrl);
  }

  Map<String, String> getCredits() {
    return {
      'data_source': 'INGV (Istituto Nazionale di Geofisica e Vulcanologia)',
      'api_url': _ingvApiUrl,
      'ingv_website': _ingvWebsite,
      'developer': _developerName,
      'app_website': _appWebsite,
    };
  }

  Map<String, String> getLegalInfo() {
    return {
      'privacy_policy': _privacyPolicyUrl,
      'terms_of_service': _termsOfServiceUrl,
      'data_source': 'INGV Web Services API',
      'data_license': 'Open Data License',
    };
  }
}
