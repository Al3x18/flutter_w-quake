import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../services/settings_storage_service.dart';
import '../../providers/location_providers.dart';

class LocationSettingsPage extends ConsumerStatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  ConsumerState<LocationSettingsPage> createState() =>
      _LocationSettingsPageState();
}

class _LocationSettingsPageState extends ConsumerState<LocationSettingsPage> {
  late SettingsStorageService _settingsService;
  bool _isLocationEnabled = false;
  bool _showUserLocation = false;
  bool _isLoading = true;
  int _radiusKm = 100;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsStorageService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final locationEnabled = await _settingsService.loadLocationEnabled();
      final showUserLocation = await _settingsService.loadShowUserLocation();
      final radiusKm = await _settingsService.loadLocationRadiusKm();

      setState(() {
        _isLocationEnabled = locationEnabled;
        _showUserLocation = showUserLocation;
        _isLoading = false;
        _radiusKm = radiusKm;
      });

      ref.invalidate(locationRadiusKmProvider);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLocationEnabled(bool enabled) async {
    try {
      await _settingsService.saveLocationEnabled(enabled);
      setState(() {
        _isLocationEnabled = enabled;
      });

      ref.invalidate(locationEnabledSettingProvider);
      ref.invalidate(showUserLocationSettingProvider);
      ref.invalidate(userPositionProvider);

      if (enabled) {
        final locationViewModel = ref.read(locationViewModelProvider.notifier);
        await locationViewModel.requestLocationPermission();

        final locationState = ref.read(locationViewModelProvider);
        if (locationState.hasPermission &&
            locationState.currentPosition != null) {
          await _settingsService.saveShowUserLocation(true);
          setState(() {
            _showUserLocation = true;
          });

          ref.invalidate(showUserLocationSettingProvider);
          ref.invalidate(userPositionProvider);

          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.locationEnabledSuccess,
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 20, left: 16, right: 16),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        final locationViewModel = ref.read(locationViewModelProvider.notifier);
        locationViewModel.stopLocationUpdates();

        await _settingsService.saveShowUserLocation(false);
        setState(() {
          _showUserLocation = false;
        });

        ref.invalidate(showUserLocationSettingProvider);
        ref.invalidate(userPositionProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleShowUserLocation(bool show) async {
    try {
      await _settingsService.saveShowUserLocation(show);
      setState(() {
        _showUserLocation = show;
      });

      ref.invalidate(showUserLocationSettingProvider);
      ref.invalidate(userPositionProvider);

      if (show && _isLocationEnabled) {
        final locationViewModel = ref.read(locationViewModelProvider.notifier);
        await locationViewModel.startLocationUpdates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationState = ref.watch(locationViewModelProvider);

    ref.listen<LocationState>(locationViewModelProvider, (previous, next) {
      if (_isLocationEnabled &&
          next.hasPermission &&
          next.currentPosition != null &&
          !_showUserLocation) {
        _settingsService.saveShowUserLocation(true);
        setState(() {
          _showUserLocation = true;
        });
      }
    });

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(l10n.locationPermission),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.locationPermission),
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
              l10n.locationPermissionDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),

            _buildSettingsCard(
              icon: Icons.location_on,
              title: l10n.enableLocation,
              subtitle: l10n.allowLocationAccess,
              trailing: Switch.adaptive(
                value: _isLocationEnabled,
                onChanged: _toggleLocationEnabled,
                activeThumbColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLocationEnabled) ...[
              _buildSettingsCard(
                icon: Icons.my_location,
                title: l10n.showMyLocation,
                subtitle: l10n.showLocationOnMap,
                trailing: Switch.adaptive(
                  value: _showUserLocation,
                  onChanged: _toggleShowUserLocation,
                  activeThumbColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              if (ref.watch(locationViewModelProvider).hasPermission) ...[
                _buildRadiusCard(l10n),
                const SizedBox(height: 16),
              ],
            ],

            if (_isLocationEnabled) ...[
              _buildStatusCard(locationState, l10n),
              const SizedBox(height: 16),
            ],

            if (locationState.hasError) ...[
              _buildErrorCard(locationState.error!, l10n),
              const SizedBox(height: 16),
            ],

            if (locationState.hasPermission == false) ...[
              _buildActionCard(
                icon: Icons.settings,
                title: l10n.openAppSettings,
                subtitle: l10n.enableLocationPermissionsManually,
                onTap: _openAppSettings,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
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
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(LocationState locationState, AppLocalizations l10n) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (locationState.hasLocation) {
      statusColor = Colors.green;
      statusText = l10n.locationAccessGranted;
      statusIcon = Icons.check_circle;
    } else if (locationState.isLoading) {
      statusColor = Colors.orange;
      statusText = l10n.requestingLocationAccess;
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = Colors.red;
      statusText = l10n.locationAccessDenied;
      statusIcon = Icons.error;
    }

    return Card(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, AppLocalizations l10n) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
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

  Widget _buildRadiusCard(AppLocalizations l10n) {
    return Card(
      color: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.radar,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.searchRadius,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.searchRadiusSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.nearbyIndicatorDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[300],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '$_radiusKm km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _radiusKm.toDouble(),
              min: 20,
              max: 300,
              divisions: 28,
              activeColor: Colors.orange,
              inactiveColor: Colors.grey[700],
              label: '$_radiusKm km',
              onChanged: (v) async {
                final int km = v.round();
                setState(() => _radiusKm = km);

                ref.invalidate(locationRadiusKmProvider);
                await _settingsService.saveLocationRadiusKm(km);
              },
            ),
          ],
        ),
      ),
    );
  }
}
