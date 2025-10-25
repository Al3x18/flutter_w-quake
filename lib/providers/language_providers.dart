import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import '../services/language_service.dart';

/// Language Service provider
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

/// Language state
class LanguageState {
  final String currentLanguage;
  final bool isInitialized;

  const LanguageState({
    this.currentLanguage = 'en',
    this.isInitialized = false,
  });

  LanguageState copyWith({
    String? currentLanguage,
    bool? isInitialized,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Language ViewModel (Notifier)
/// Manages language business logic and state
class LanguageNotifier extends Notifier<LanguageState> {
  // Available languages with localized names
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'it': 'Italiano',
  };

  LanguageService get _service => ref.read(languageServiceProvider);

  @override
  LanguageState build() {
    _loadSavedLanguage();
    return const LanguageState();
  }

  /// Load saved language from storage
  Future<void> _loadSavedLanguage() async {
    try {
      final currentLanguage = await _service.loadLanguage();
      debugPrint('[Language] Loaded: $currentLanguage');
      state = state.copyWith(
        currentLanguage: currentLanguage,
        isInitialized: true,
      );
    } catch (e) {
      debugPrint('[Language ERROR] Failed to load: $e');
      state = state.copyWith(
        currentLanguage: _service.getDefaultLanguage(),
        isInitialized: true,
      );
    }
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    // Validate language code
    if (!_isValidLanguageCode(languageCode)) {
      debugPrint('[Language ERROR] Invalid code: $languageCode');
      return;
    }

    try {
      await _service.saveLanguage(languageCode);
      state = state.copyWith(currentLanguage: languageCode);
      debugPrint('[Language] Changed to: $languageCode');
    } catch (e) {
      debugPrint('[Language ERROR] Failed to change: $e');
    }
  }

  /// Reset to default language
  Future<void> resetToDefault() async {
    try {
      await _service.clearLanguage();
      final defaultLanguage = _service.getDefaultLanguage();
      state = state.copyWith(currentLanguage: defaultLanguage);
      debugPrint('[Language] Reset to default: $defaultLanguage');
    } catch (e) {
      debugPrint('[Language ERROR] Failed to reset: $e');
    }
  }

  /// Get available languages with names
  List<Map<String, String>> getAvailableLanguages() {
    return _languageNames.entries
        .map((e) => {'code': e.key, 'name': e.value})
        .toList();
  }

  /// Get language name by code
  String getLanguageName(String code) {
    return _languageNames[code] ?? 'English';
  }

  /// Validate language code
  bool _isValidLanguageCode(String code) {
    return _service.getSupportedLanguages().contains(code);
  }
}

/// Language provider
final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(
  () => LanguageNotifier(),
);
