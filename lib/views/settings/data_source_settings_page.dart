import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/earthquake_source.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/custom_snackbar.dart';

class DataSourceSettingsPage extends ConsumerStatefulWidget {
  const DataSourceSettingsPage({super.key});

  @override
  ConsumerState<DataSourceSettingsPage> createState() =>
      _DataSourceSettingsPageState();
}

class _DataSourceSettingsPageState
    extends ConsumerState<DataSourceSettingsPage> {
  EarthquakeSource? selectedSource;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsState = ref.read(defaultSettingsProvider);
      setState(() {
        selectedSource = settingsState.source;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(defaultSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.dataSource),
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
            Text(
              l10n.selectDataSourceDescription,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
            ),
            const SizedBox(height: 18),

            ...EarthquakeSource.values.map((source) {
              final isSelected = selectedSource == source;
              String sourceName;
              switch (source) {
                case EarthquakeSource.ingv:
                  sourceName = l10n.sourceIngv;
                  break;
                case EarthquakeSource.usgs:
                  sourceName = l10n.sourceUsgs;
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.orange : Colors.grey[800]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedSource = source;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.grey[800]!.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.storage,
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey[400],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sourceName,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),

                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedSource != null &&
                        selectedSource != settingsState.source
                    ? () => _saveSource(selectedSource!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.saveSettings,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSource(EarthquakeSource source) async {
    try {
      await ref
          .read(defaultSettingsProvider.notifier)
          .setEarthquakeSource(source);

      if (mounted) {
        AnimatedSnackBarHelper.showSuccess(
          context,
          AppLocalizations.of(context)!.settingsSavedSuccessfully,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AnimatedSnackBarHelper.showError(
          context,
          AppLocalizations.of(context)!.errorSavingSettings(e.toString()),
        );
      }
    }
  }
}
