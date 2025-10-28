import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/settings_page_viewmodel.dart';

final settingsPageViewModelProvider =
    NotifierProvider<SettingsPageViewModel, SettingsPageState>(
  () => SettingsPageViewModel(),
);
