import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling app information and external links
/// This is the Model layer in MVVM pattern
class InformationService {
  static const String _appName = 'W-Quake';
  static const String _appDescription = 'Real-time earthquake monitoring app';
  static const String _developerName = 'Alex De Pasquale';
  static const String _appWebsite = '';
  static const String _privacyPolicyUrl = '';
  static const String _termsOfServiceUrl = '';
  static const String _ingvApiUrl = 'https://webservices.ingv.it/';
  static const String _ingvWebsite = 'https://www.ingv.it/';

  /// Get app package information
  Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('[InformationService] Error getting package info: $e');
      rethrow;
    }
  }

  /// Get app version string
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await getPackageInfo();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      debugPrint('[InformationService] Error getting app version: $e');
      return 'Unknown';
    }
  }

  /// Get app version only (without build number)
  Future<String> getVersionOnly() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.version;
    } catch (e) {
      debugPrint('[InformationService] Error getting version: $e');
      return 'Unknown';
    }
  }

  /// Get build number only
  Future<String> getBuildNumber() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.buildNumber;
    } catch (e) {
      debugPrint('[InformationService] Error getting build number: $e');
      return 'Unknown';
    }
  }

  /// Get package name
  Future<String> getPackageName() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.packageName;
    } catch (e) {
      debugPrint('[InformationService] Error getting package name: $e');
      return 'Unknown';
    }
  }

  /// Get app name from package info
  Future<String> getAppNameFromPackage() async {
    try {
      final packageInfo = await getPackageInfo();
      return packageInfo.appName;
    } catch (e) {
      debugPrint('[InformationService] Error getting app name from package: $e');
      return _appName; // Fallback to static name
    }
  }

  /// Get app name
  String getAppName() => _appName;

  /// Get app description
  String getAppDescription() => _appDescription;

  /// Get developer name
  String getDeveloperName() => _developerName;

  /// Get app website URL
  String getAppWebsite() => _appWebsite;

  /// Get privacy policy URL
  String getPrivacyPolicyUrl() => _privacyPolicyUrl;

  /// Get terms of service URL
  String getTermsOfServiceUrl() => _termsOfServiceUrl;

  /// Get INGV API URL
  String getIngvApiUrl() => _ingvApiUrl;

  /// Get INGV website URL
  String getIngvWebsite() => _ingvWebsite;

  /// Launch external URL
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

  /// Launch app website
  Future<bool> launchAppWebsite() async {
    return await launchExternalUrl(_appWebsite);
  }

  /// Launch privacy policy
  Future<bool> launchPrivacyPolicy() async {
    return await launchExternalUrl(_privacyPolicyUrl);
  }

  /// Launch terms of service
  Future<bool> launchTermsOfService() async {
    return await launchExternalUrl(_termsOfServiceUrl);
  }

  /// Launch INGV website
  Future<bool> launchIngvWebsite() async {
    return await launchExternalUrl(_ingvWebsite);
  }

  /// Launch INGV API documentation
  Future<bool> launchIngvApiDocumentation() async {
    return await launchExternalUrl(_ingvApiUrl);
  }

  /// Get credits information
  Map<String, String> getCredits() {
    return {'data_source': 'INGV (Istituto Nazionale di Geofisica e Vulcanologia)', 'api_url': _ingvApiUrl, 'ingv_website': _ingvWebsite, 'developer': _developerName, 'app_website': _appWebsite};
  }

  /// Get legal information
  Map<String, String> getLegalInfo() {
    return {'privacy_policy': _privacyPolicyUrl, 'terms_of_service': _termsOfServiceUrl, 'data_source': 'INGV Web Services API', 'data_license': 'Open Data License'};
  }
}
