import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'en';
  static const List<String> _supportedLanguages = ['en', 'it'];

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await _preferences;
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> loadLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  Future<void> clearLanguage() async {
    final prefs = await _preferences;
    await prefs.remove(_languageKey);
  }

  List<String> getSupportedLanguages() => _supportedLanguages;

  String getDefaultLanguage() => _defaultLanguage;
}
