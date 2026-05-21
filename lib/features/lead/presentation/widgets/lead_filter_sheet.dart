import 'package:flutter/material.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../l10n/app_localizations.dart';

class LeadFilterSheet extends StatelessWidget {
  const LeadFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.filter,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.lg),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Sort by date'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Filter by salesperson'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.source),
            title: const Text('Filter by source'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
