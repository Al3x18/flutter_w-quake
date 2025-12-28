import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState {
  final Locale currentLocale;
  final bool isInitialized;

  const LanguageState({
    this.currentLocale = const Locale('en'),
    this.isInitialized = false,
  });

  LanguageState copyWith({Locale? currentLocale, bool? isInitialized}) {
    return LanguageState(
      currentLocale: currentLocale ?? this.currentLocale,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class LanguageNotifier extends AsyncNotifier<LanguageState> {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguageCode = 'en';
  static const Map<String, String> _supportedLanguages = {
    'en': 'English',
    'it': 'Italiano',
  };

  @override
  Future<LanguageState> build() async {
    return _loadSavedLanguage();
  }

  Future<LanguageState> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_languageKey) ?? _defaultLanguageCode;

      return LanguageState(
        currentLocale: Locale(savedCode),
        isInitialized: true,
      );
    } catch (e) {
      debugPrint('[LanguageNotifier] Error loading language: $e');
      return const LanguageState(
        currentLocale: Locale(_defaultLanguageCode),
        isInitialized: true,
      );
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!_supportedLanguages.containsKey(languageCode)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    state = AsyncData(
      state.value!.copyWith(currentLocale: Locale(languageCode)),
    );
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);

    state = AsyncData(
      state.value!.copyWith(currentLocale: const Locale(_defaultLanguageCode)),
    );
  }

  Map<String, String> getAvailableLanguages() => _supportedLanguages;

  String getLanguageName(String code) => _supportedLanguages[code] ?? 'English';
}

final languageProvider = AsyncNotifierProvider<LanguageNotifier, LanguageState>(
  LanguageNotifier.new,
);
