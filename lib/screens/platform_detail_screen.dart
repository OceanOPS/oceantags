import 'package:flutter/material.dart';
import '../database/db.dart';

class PlatformDetailScreen extends StatelessWidget {
  final PlatformEntity platform;

  const PlatformDetailScreen({Key? key, required this.platform}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          platform.reference,
          style: textTheme.titleLarge,
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Platform Reference
            Card(
              elevation: 2,
              color: colorScheme.surfaceVariant,
              child: ListTile(
                leading: Icon(Icons.storage, color: colorScheme.primary),
                title: Text(
                  platform.reference,
                  style: textTheme.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Location
            Card(
              elevation: 1,
              color: colorScheme.surfaceVariant,
              child: ListTile(
                leading: Icon(Icons.location_on, color: colorScheme.error),
                title: Text("Location", style: textTheme.titleMedium),
                subtitle: Text(
                  "${platform.latitude}; ${platform.longitude}",
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Status with Color Indicator
            Card(
              elevation: 1,
              color: colorScheme.surfaceVariant,
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: platform.status == "Active" ? colorScheme.primary : colorScheme.error,
                ),
                title: Text("Status", style: textTheme.titleMedium),
                subtitle: Text(
                  platform.status,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: platform.status == "Active" ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Network Information
            Card(
              elevation: 1,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Network:", style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      platform.network,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Action Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.edit),
                label: Text("Edit Platform"),
                onPressed: () {
                  print("Edit button clicked!");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
