import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? l10n.loadingEvents,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[200]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
