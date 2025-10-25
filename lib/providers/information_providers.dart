import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import '../services/information_service.dart';

/// Provider for InformationService
final informationServiceProvider = Provider<InformationService>((ref) {
  return InformationService();
});

/// State class for app information
class InformationState {
  final String appVersion;
  final String versionOnly;
  final String buildNumber;
  final String packageName;
  final String appName;
  final String appDescription;
  final String developerName;
  final bool isLoading;
  final String? error;

  const InformationState({
    this.appVersion = 'Unknown',
    this.versionOnly = 'Unknown',
    this.buildNumber = 'Unknown',
    this.packageName = 'Unknown',
    this.appName = 'W-Quake',
    this.appDescription = 'Real-time earthquake monitoring app',
    this.developerName = 'W-Quake Team',
    this.isLoading = false,
    this.error,
  });

  InformationState copyWith({
    String? appVersion,
    String? versionOnly,
    String? buildNumber,
    String? packageName,
    String? appName,
    String? appDescription,
    String? developerName,
    bool? isLoading,
    String? error,
  }) {
    return InformationState(
      appVersion: appVersion ?? this.appVersion,
      versionOnly: versionOnly ?? this.versionOnly,
      buildNumber: buildNumber ?? this.buildNumber,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appDescription: appDescription ?? this.appDescription,
      developerName: developerName ?? this.developerName,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing app information state
class InformationNotifier extends Notifier<InformationState> {
  InformationService get _service => ref.read(informationServiceProvider);

  @override
  InformationState build() {
    // Load app information asynchronously after build
    Future.microtask(() => _loadAppInformation());
    return const InformationState();
  }

  /// Load app information from package info
  Future<void> _loadAppInformation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get all package information
      final appVersion = await _service.getAppVersion();
      final versionOnly = await _service.getVersionOnly();
      final buildNumber = await _service.getBuildNumber();
      final packageName = await _service.getPackageName();
      final appNameFromPackage = await _service.getAppNameFromPackage();
      final appDescription = _service.getAppDescription();
      final developerName = _service.getDeveloperName();

      state = state.copyWith(
        appVersion: appVersion,
        versionOnly: versionOnly,
        buildNumber: buildNumber,
        packageName: packageName,
        appName: appNameFromPackage,
        appDescription: appDescription,
        developerName: developerName,
        isLoading: false,
        error: null,
      );

      debugPrint('[Information] App info loaded successfully');
      debugPrint('[Information] Version: $versionOnly, Build: $buildNumber, Package: $packageName');
    } catch (e) {
      debugPrint('[Information ERROR] Failed to load app info: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh app information
  Future<void> refreshAppInformation() async {
    await _loadAppInformation();
  }

  /// Launch external URL
  Future<bool> launchUrl(String url) async {
    try {
      final success = await _service.launchExternalUrl(url);
      if (success) {
        debugPrint('[Information] Successfully launched URL: $url');
      } else {
        debugPrint('[Information] Failed to launch URL: $url');
      }
      return success;
    } catch (e) {
      debugPrint('[Information ERROR] Error launching URL: $e');
      return false;
    }
  }

  /// Launch app website
  Future<bool> launchAppWebsite() async {
    return await _service.launchAppWebsite();
  }

  /// Launch privacy policy
  Future<bool> launchPrivacyPolicy() async {
    return await _service.launchPrivacyPolicy();
  }

  /// Launch terms of service
  Future<bool> launchTermsOfService() async {
    return await _service.launchTermsOfService();
  }

  /// Launch INGV website
  Future<bool> launchIngvWebsite() async {
    return await _service.launchIngvWebsite();
  }

  /// Launch INGV API documentation
  Future<bool> launchIngvApiDocumentation() async {
    return await _service.launchIngvApiDocumentation();
  }

  /// Get credits information
  Map<String, String> getCredits() {
    return _service.getCredits();
  }

  /// Get legal information
  Map<String, String> getLegalInfo() {
    return _service.getLegalInfo();
  }

  /// Get app website URL
  String getAppWebsite() {
    return _service.getAppWebsite();
  }

  /// Get privacy policy URL
  String getPrivacyPolicyUrl() {
    return _service.getPrivacyPolicyUrl();
  }

  /// Get terms of service URL
  String getTermsOfServiceUrl() {
    return _service.getTermsOfServiceUrl();
  }

  /// Get INGV website URL
  String getIngvWebsite() {
    return _service.getIngvWebsite();
  }

  /// Get INGV API URL
  String getIngvApiUrl() {
    return _service.getIngvApiUrl();
  }
}

/// Provider for InformationNotifier
final informationProvider = NotifierProvider<InformationNotifier, InformationState>(() => InformationNotifier());
