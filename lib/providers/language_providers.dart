import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';

// Service provider
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});
