import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../models/earthquake_source.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(defaultSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.manageAppSettings,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
            ),
            const SizedBox(height: 18),

            _buildSettingsCard(
              icon: Icons.storage,
              title: l10n.dataSource,
              subtitle: settingsState.source == EarthquakeSource.ingv
                  ? l10n.sourceIngv
                  : l10n.sourceUsgs,
              onTap: () {
                context.push('/settings/data-source');
              },
            ),
            const SizedBox(height: 16),

            _buildSettingsCard(
              icon: Icons.filter_list,
              title: l10n.defaultFilters,
              subtitle: l10n.setDefaultFilters,
              onTap: () {
                context.push('/settings/filters');
              },
            ),
            const SizedBox(height: 16),

            _buildSettingsCard(
              icon: Icons.language,
              title: l10n.appLanguage,
              subtitle: l10n.selectAppLanguage,
              onTap: () {
                context.push('/settings/language');
              },
            ),
            const SizedBox(height: 16),

            _buildSettingsCard(
              icon: Icons.location_on,
              title: l10n.locationPermission,
              subtitle: l10n.locationPermissionDescription,
              onTap: () {
                context.push('/settings/location');
              },
            ),
            const SizedBox(height: 16),

            _buildSettingsCard(
              icon: Icons.info,
              title: l10n.information,
              subtitle: l10n.viewAppInfo,
              onTap: () {
                context.push('/settings/information');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
