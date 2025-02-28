import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // ✅ For GPS Location
import '../database/db.dart';

class PlatformDetailScreen extends StatefulWidget {
  final PlatformEntity platform;
  final AppDatabase database; // ✅ Add Database
  final VoidCallback? onPlatformUpdated;

  const PlatformDetailScreen({Key? key, required this.platform, required this.database, this.onPlatformUpdated,})
      : super(key: key);

  @override
  _PlatformDetailScreenState createState() => _PlatformDetailScreenState();
}

class _PlatformDetailScreenState extends State<PlatformDetailScreen> {
  LatLng? _currentLocation;
  late PlatformEntity _platform;

  @override
  void initState() {
    super.initState();
    _platform = widget.platform; 
    _getCurrentLocation();
  }

  /// ✅ Get User's Current Location
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }

  /// ✅ Show Confirmation Modal
  void _showDeployConfirmation() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to get current location.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deployment"),
          content: Text(
            "Update deployment details for platform '${_platform.reference}' "
            "to current time and location:\n\n"
            "🕒 Time: ${DateTime.now().toUtc().toString().split('.')[0]} UTC\n"
            "📍 Latitude: ${_currentLocation!.latitude}\n"
            "📍 Longitude: ${_currentLocation!.longitude}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deployPlatform();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

/// ✅ Deploy Platform to Current Location
void _deployPlatform() async {
  if (_currentLocation != null) {
    await widget.database.updateDeployment(
      _platform.reference,
      lat: _currentLocation!.latitude,
      lon: _currentLocation!.longitude,
    );

     // ✅ Fetch updated platform details from the database
    final updatedPlatform = await widget.database.getPlatformByReference(_platform.reference);

    if (updatedPlatform != null) {
      setState(() {
        _platform = updatedPlatform;
      });
      // ✅ Call the refresh function in SearchScreen if it exists
      widget.onPlatformUpdated?.call();
    }

    // ✅ Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Platform '${_platform.reference}' deployment details updated!")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_platform.reference, style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // 🔹 Interactive Map Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_platform.latitude, _platform.longitude),
                  initialZoom: 3.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_platform.latitude, _platform.longitude),
                        child: Icon(Icons.location_on, color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Platform Details Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Platform Info with Favorite Button
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              _getNetworkImage(_platform.network),
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleFavorite(_platform),
                                      child: Icon(
                                        _platform.isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: _platform.isFavorite ? Colors.red : Colors.grey,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _platform.reference,
                                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildStatusBadge(_platform.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                    context, Icons.location_on, "Location",
                                    "${_platform.latitude}, ${_platform.longitude}", Colors.redAccent),
                                _buildInfoRow(context, Icons.wifi, "Network", _platform.network, Colors.blueAccent),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(context, null, "Model", _platform.model, null),
                      _buildInfoRow(context, null, "Deployment date", _platform.deploymentDate?.toIso8601String() ?? "N/A", null),
                      _buildInfoRow(context, null, "Deployment latidtude", _platform.deploymentLatitude?.toString() ?? "N/A", null),
                      _buildInfoRow(context, null, "Deployment longitude", _platform.deploymentLongitude?.toString() ?? "N/A", null),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 🔹 Floating Action Button (Deploy Platform)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDeployConfirmation,
        label: Text("Deploy"),
        icon: Icon(Icons.location_searching),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.primary,
      ),
    );
  }

  /// 🔹 Status Badge Widget
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🔹 Info Row Widget
  Widget _buildInfoRow(BuildContext context, IconData? icon, String title, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          icon != null ? Icon(icon, color: color, size: 20) : const SizedBox(width: 0),
          const SizedBox(width: 6),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  /// 🔹 Get Status Color
  Color _getStatusColor(String status) {
    switch (status) {
      case "OPERATIONAL":
        return Colors.green;
      case "INACTIVE":
        return Colors.redAccent;
      case "PROBABLE":
        return Colors.orangeAccent;
      case "REGISTERED":
        return Colors.blueAccent;
      case "CONFIRMED":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 🔹 Get Network Image for Platform
  String _getNetworkImage(String network) {
    Map<String, String> networkImages = {
      'argo': 'assets/images/argo.png',
      'dbcp': 'assets/images/drifter.png',
      'oceansites': 'assets/images/buoy.png',
      'sot': 'assets/images/ship.png',
      'oceangliders': 'assets/images/glider.png',
      'anibos': 'assets/images/anibos.png',
    };
    return networkImages[network.toLowerCase()] ?? 'assets/images/default.png';
  }

  /// 🔹 Toggle Favorite
  void _toggleFavorite(PlatformEntity platform) {
    print("Toggled favorite for: ${platform.reference}");
  }
}
