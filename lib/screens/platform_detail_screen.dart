import 'package:flutter/material.dart';
import '../platform_model.dart';

class PlatformDetailScreen extends StatelessWidget {
  final PlatformModel platform;

  const PlatformDetailScreen({Key? key, required this.platform}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(platform.reference)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Titre avec icône
            Row(
              children: [
                Icon(Icons.storage, color: Colors.blueAccent, size: 30),
                SizedBox(width: 10),
                Text(
                  platform.reference,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 🔹 Localisation
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Localisation : ${platform.latitude};${platform.longitude}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 12),

            // 🔹 Statut avec badge coloré
            Row(
              children: [
                Icon(Icons.check_circle, color: platform.status == "Active" ? Colors.green : Colors.red),
                SizedBox(width: 8),
                Text(
                  "Statut : ${platform.status}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: platform.status == "Active" ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // 🔹 Description
            Text(
              "Network :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              platform.network,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}