import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
      body: Column(
        children: [
          // 🔹 Small Map at the Top
          Container(
            height: 200,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)), // ✅ Rounded corners
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(platform.latitude, platform.longitude),
                  initialZoom: 5.0, // ✅ Adjust zoom level
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(platform.latitude, platform.longitude),
                        child: Icon(Icons.location_on, color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Details Below Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildDetailCard(
                    icon: Icons.storage,
                    title: "Reference",
                    value: platform.reference,
                    color: colorScheme.primary,
                    textTheme: textTheme,
                  ),
                  _buildDetailCard(
                    icon: Icons.location_on,
                    title: "Location",
                    value: "${platform.latitude}, ${platform.longitude}",
                    color: Colors.redAccent,
                    textTheme: textTheme,
                  ),
                  _buildDetailCard(
                    icon: Icons.check_circle,
                    title: "Status",
                    value: platform.status,
                    color: platform.status == "Active" ? colorScheme.primary : Colors.red,
                    textTheme: textTheme,
                  ),
                  _buildDetailCard(
                    icon: Icons.wifi,
                    title: "Network",
                    value: platform.network,
                    color: Colors.blueAccent,
                    textTheme: textTheme,
                  ),
                  _buildDetailCard(
                    icon: Icons.devices_other,
                    title: "Model",
                    value: platform.model,
                    color: Colors.orange,
                    textTheme: textTheme,
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Edit Button
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
          ),
        ],
      ),
    );
  }

  /// 🔹 Reusable Detail Card Widget
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required TextTheme textTheme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // ✅ Soft rounded corners
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: textTheme.titleMedium),
        subtitle: Text(value, style: textTheme.bodyMedium),
      ),
    );
  }
}
