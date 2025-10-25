import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/information_providers.dart';
import '../../widgets/custom_snackbar.dart';

class InformationSettingsPage extends ConsumerStatefulWidget {
  const InformationSettingsPage({super.key});

  @override
  ConsumerState<InformationSettingsPage> createState() => _InformationSettingsPageState();
}

class _InformationSettingsPageState extends ConsumerState<InformationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final informationState = ref.watch(informationProvider);
    final informationNotifier = ref.read(informationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.information),
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
      body: informationState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Information Section
                  _buildSectionTitle(l10n.information),
                  const SizedBox(height: 12),
                  _buildAppInfoCard(l10n, informationState, informationNotifier),
                  const SizedBox(height: 24),

                  // Credits Section
                  _buildSectionTitle(l10n.credits),
                  const SizedBox(height: 12),
                  _buildCreditsCard(l10n, informationNotifier),
                  const SizedBox(height: 24),

                  // Legal Information Section
                  _buildSectionTitle(l10n.legalInformation),
                  const SizedBox(height: 12),
                  _buildLegalInfoCard(l10n, informationNotifier),
                  const SizedBox(height: 24),

                  // Data Source Section
                  _buildSectionTitle(l10n.dataSource),
                  const SizedBox(height: 12),
                  _buildDataSourceCard(l10n, informationNotifier),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAppInfoCard(AppLocalizations l10n, InformationState state, InformationNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.info, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.appName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(state.appDescription, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(l10n.version, state.versionOnly),
          _buildInfoRow(l10n.build, state.buildNumber),
          _buildInfoRow(l10n.developer, state.developerName),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await notifier.launchAppWebsite();
                if (mounted) {
                  if (success) {
                    AnimatedSnackBarHelper.showSuccess(context, 'Website opened successfully');
                  } else {
                    AnimatedSnackBarHelper.showError(context, 'Failed to open website');
                  }
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(l10n.openWebsite),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsCard(AppLocalizations l10n, InformationNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.credits,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.dataProvider, l10n.ingvInstitute),
          _buildInfoRow(l10n.license, l10n.openDataLicense),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await notifier.launchIngvWebsite();
                    if (mounted) {
                      if (success) {
                        AnimatedSnackBarHelper.showSuccess(context, 'INGV website opened');
                      } else {
                        AnimatedSnackBarHelper.showError(context, 'Failed to open INGV website');
                      }
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: Text(l10n.openWebsite, style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await notifier.launchIngvApiDocumentation();
                    if (mounted) {
                      if (success) {
                        AnimatedSnackBarHelper.showSuccess(context, 'API documentation opened');
                      } else {
                        AnimatedSnackBarHelper.showError(context, 'Failed to open API documentation');
                      }
                    }
                  },
                  icon: const Icon(Icons.description, size: 14),
                  label: Text(l10n.viewDocumentation, style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalInfoCard(AppLocalizations l10n, InformationNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.gavel, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.legalInformation,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await notifier.launchPrivacyPolicy();
                    if (mounted) {
                      if (success) {
                        AnimatedSnackBarHelper.showSuccess(context, 'Privacy policy opened');
                      } else {
                        AnimatedSnackBarHelper.showError(context, 'Failed to open privacy policy');
                      }
                    }
                  },
                  icon: const Icon(Icons.privacy_tip, size: 16),
                  label: Text(l10n.privacyPolicy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await notifier.launchTermsOfService();
                    if (mounted) {
                      if (success) {
                        AnimatedSnackBarHelper.showSuccess(context, 'Terms of service opened');
                      } else {
                        AnimatedSnackBarHelper.showError(context, 'Failed to open terms of service');
                      }
                    }
                  },
                  icon: const Icon(Icons.description, size: 16),
                  label: Text(l10n.termsOfService),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard(AppLocalizations l10n, InformationNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.api, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.dataSource,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('API URL', notifier.getIngvApiUrl()),
          _buildInfoRow('Data Format', 'GeoJSON'),
          _buildInfoRow('Update Frequency', 'Real-time'),
          _buildInfoRow('Coverage', 'Global'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
