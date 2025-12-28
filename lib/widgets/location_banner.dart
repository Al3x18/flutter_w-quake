import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/first_launch_provider.dart';
import 'custom_snackbar.dart';

class LocationBanner extends ConsumerWidget {
  const LocationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFirstLaunch = ref.watch(isFirstLaunchProvider);

    if (!isFirstLaunch) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.locationPermissionDescription,
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(firstLaunchProvider.notifier).markFirstLaunchCompleted();
                  if (context.mounted) {
                    AnimatedSnackBarHelper.showInfo(context, l10n.locationCanBeEnabledLater);
                  }
                },
                icon: const Icon(Icons.close, color: Colors.black, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                context.push('/settings/location');
                ref.read(firstLaunchProvider.notifier).markFirstLaunchCompleted();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(l10n.goToLocationSettings, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

