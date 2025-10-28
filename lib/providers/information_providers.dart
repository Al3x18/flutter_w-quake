import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/information_service.dart';

// Service provider
final informationServiceProvider = Provider<InformationService>((ref) {
  return InformationService();
});
