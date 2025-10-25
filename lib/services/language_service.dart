import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing language persistence
/// Handles only data access layer (SharedPreferences)
class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';
  static const List<String> _supportedLanguages = ['en', 'it'];

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance (lazy initialization)
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save the selected language
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(_languageKey, languageCode);
  }

  /// Load the saved language or return default
  Future<String> loadLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Clear the saved language
  Future<void> clearLanguage() async {
    final prefs = await _preferences;
    await prefs.remove(_languageKey);
  }

  /// Get supported language codes
  List<String> getSupportedLanguages() => _supportedLanguages;

  /// Get default language code
  String getDefaultLanguage() => _defaultLanguage;
}
