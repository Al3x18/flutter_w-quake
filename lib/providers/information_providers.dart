import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/information_service.dart';

final informationServiceProvider = Provider<InformationService>((ref) {
  return InformationService();
});

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

class InformationNotifier extends Notifier<InformationState> {
  InformationService get _service => ref.read(informationServiceProvider);

  @override
  InformationState build() {
    Future.microtask(() => _loadAppInformation());
    return const InformationState();
  }

  Future<void> _loadAppInformation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAppInformation() async {
    await _loadAppInformation();
  }

  Future<bool> launchUrl(String url) async {
    try {
      final success = await _service.launchExternalUrl(url);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> launchAppWebsite() async {
    return await _service.launchAppWebsite();
  }

  Future<bool> launchPrivacyPolicy() async {
    return await _service.launchPrivacyPolicy();
  }

  Future<bool> launchTermsOfService() async {
    return await _service.launchTermsOfService();
  }

  Future<bool> launchIngvWebsite() async {
    return await _service.launchIngvWebsite();
  }

  Future<bool> launchIngvApiDocumentation() async {
    return await _service.launchIngvApiDocumentation();
  }

  Future<bool> launchUsgsWebsite() async {
    return await _service.launchUsgsWebsite();
  }

  Future<bool> launchUsgsApiDocumentation() async {
    return await _service.launchUsgsApiDocumentation();
  }

  Map<String, String> getCredits() {
    return _service.getCredits();
  }

  Map<String, String> getLegalInfo() {
    return _service.getLegalInfo();
  }

  String getAppWebsite() {
    return _service.getAppWebsite();
  }

  String getPrivacyPolicyUrl() {
    return _service.getPrivacyPolicyUrl();
  }

  String getTermsOfServiceUrl() {
    return _service.getTermsOfServiceUrl();
  }

  String getIngvWebsite() {
    return _service.getIngvWebsite();
  }

  String getIngvApiUrl() {
    return _service.getIngvApiUrl();
  }
}

final informationProvider =
    NotifierProvider<InformationNotifier, InformationState>(() {
      return InformationNotifier();
    });
