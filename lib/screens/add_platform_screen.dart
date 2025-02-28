import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/db.dart';

class AddPlatformScreen extends StatelessWidget {

  const AddPlatformScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add platform", style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // 🔹 Interactive Map Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)), // ✅ Rounded bottom corners
            child: SizedBox(
              height: 200,
              width: double.infinity,
              // child: FlutterMap(
              //   options: MapOptions(
              //     initialCenter: LatLng(platform.latitude, platform.longitude),
              //     initialZoom: 5.0, // ✅ Adjust initial zoom
              //   ),
              //   children: [
              //     TileLayer(
              //       urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              //       subdomains: ['a', 'b', 'c'],
              //     ),
              //     MarkerLayer(
              //       markers: [
              //         Marker(
              //           point: LatLng(platform.latitude, platform.longitude),
              //           child: Icon(Icons.location_on, color: Colors.red, size: 30),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ),
          ),

          // 🔹 Platform Details (Inside a Card)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Platform Details", style: textTheme.titleLarge),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: colorScheme.primary), // ✅ Themed divider

                      // 🔹 Details List
                      // _buildInfoRow(context, Icons.storage, "Reference", platform.reference, colorScheme.primary),
                      // _buildInfoRow(context, Icons.location_on, "Location", "${platform.latitude}, ${platform.longitude}", Colors.redAccent),
                      // _buildInfoRow(context, Icons.check_circle, "Status", platform.status,
                      //   platform.status == "Active" ? colorScheme.primary : Colors.red),
                      // _buildInfoRow(context, Icons.wifi, "Network", platform.network, Colors.blueAccent),
                      // _buildInfoRow(context, Icons.devices_other, "Model", platform.model, Colors.orange),

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
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
