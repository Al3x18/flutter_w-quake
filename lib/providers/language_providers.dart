import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';

// =============================================================================
// LANGUAGE FEATURE - SERVICE, STATE, NOTIFIER
// Encapsulates app language persistence and exposes state + actions for UI.
// =============================================================================
// Service provider
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

// Language state
class LanguageState {
  final String currentLanguage;
  final bool isInitialized;

  const LanguageState({this.currentLanguage = 'en', this.isInitialized = false});

  LanguageState copyWith({String? currentLanguage, bool? isInitialized}) {
    return LanguageState(currentLanguage: currentLanguage ?? this.currentLanguage, isInitialized: isInitialized ?? this.isInitialized);
  }
}

// Notifier + provider
class LanguageNotifier extends Notifier<LanguageState> {
  static const Map<String, String> _languageNames = {'en': 'English', 'it': 'Italiano'};

  LanguageService get _service => ref.read(languageServiceProvider);

  @override
  LanguageState build() {
    _loadSavedLanguage();
    return const LanguageState();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final currentLanguage = await _service.loadLanguage();
      state = state.copyWith(currentLanguage: currentLanguage, isInitialized: true);
    } catch (e) {
      state = state.copyWith(currentLanguage: _service.getDefaultLanguage(), isInitialized: true);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!_isValidLanguageCode(languageCode)) {
      return;
    }

    try {
      await _service.saveLanguage(languageCode);
      state = state.copyWith(currentLanguage: languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetToDefault() async {
    try {
      await _service.clearLanguage();
      final defaultLanguage = _service.getDefaultLanguage();
      state = state.copyWith(currentLanguage: defaultLanguage);
    } catch (e) {
      // Handle error silently
    }
  }

  List<Map<String, String>> getAvailableLanguages() {
    return _languageNames.entries.map((e) => {'code': e.key, 'name': e.value}).toList();
  }

  String getLanguageName(String code) {
    return _languageNames[code] ?? 'English';
  }

  bool _isValidLanguageCode(String code) {
    return _service.getSupportedLanguages().contains(code);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(() {
  return LanguageNotifier();
});
