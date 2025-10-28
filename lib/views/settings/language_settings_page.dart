import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/earthquake_providers.dart';
import '../../widgets/custom_snackbar.dart';

class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    // Initialize with current language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageState = ref.read(languageProvider);
      setState(() {
        selectedLanguage = languageState.currentLanguage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageState = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.appLanguage),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectAppLanguage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[300])),
            const SizedBox(height: 18),

            // Language options
            ...ref.read(languageProvider.notifier).getAvailableLanguages().map((language) {
              final code = language['code']!;
              final name = language['name']!;
              final isSelected = selectedLanguage == code;

              return Card(
                color: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Colors.orange : Colors.grey[800]!, width: isSelected ? 2 : 1),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedLanguage = code;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Language flag/icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.grey[800]!.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.language, color: isSelected ? Colors.orange : Colors.grey[400], size: 24),
                        ),
                        const SizedBox(width: 16),
                        // Language name
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        // Selection indicator
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedLanguage != null && selectedLanguage != languageState.currentLanguage ? () => _saveLanguage(selectedLanguage!) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.saveSettings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),

            // Reset button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _resetToDefaults(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[400], padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(l10n.resetToDefaults, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      await ref.read(languageProvider.notifier).changeLanguage(languageCode);

      if (mounted) {
        AnimatedSnackBarHelper.showSuccess(context, AppLocalizations.of(context)!.settingsSavedSuccessfully);
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackBarHelper.showError(context, 'Failed to save language: $e');
      }
    }
  }

  Future<void> _resetToDefaults() async {
    try {
      await ref.read(languageProvider.notifier).resetToDefault();

      setState(() {
        selectedLanguage = 'en'; // Default language
      });

      if (mounted) {
        AnimatedSnackBarHelper.showInfo(context, AppLocalizations.of(context)!.settingsResetToDefaults);
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackBarHelper.showError(context, 'Failed to reset language: $e');
      }
    }
  }
}
