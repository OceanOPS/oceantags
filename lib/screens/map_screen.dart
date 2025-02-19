import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'dart:async';
import '../platform_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  bool _isLocationLoaded = false;
  bool _isBoxInitialized = false;
  Box<PlatformModel>? _platformBox;

  PlatformModel? _selectedPlatform;
  late final MapController _mapController;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializePlatformData();
    _getCurrentLocation();

    // ✅ Animation controller for pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.6,
      upperBound: 1.3,
    )..repeat(reverse: true);
  }

  Future<void> _initializePlatformData() async {
    try {
      _platformBox = await Hive.openBox<PlatformModel>('platforms');
      setState(() {
        _isBoxInitialized = true;
      });
    } catch (e) {
      print("❌ Error initializing platform data: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLocationLoaded = true;
    });
  }

  /// ✅ Assign different colors based on status
  Color _getPlatformColor(String status) {
    switch (status.toUpperCase()) {
      case 'INACTIVE':
        return Colors.red;
      case 'OPERATIONAL':
        return Colors.green;
      case 'CLOSED':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }


  /// ✅ Generate platform markers with larger clickable areas
  List<Marker> _platformMarkers() {
    if (!_isBoxInitialized || _platformBox == null || _platformBox!.isEmpty) return [];

    return _platformBox!.values.map((platform) {
      return Marker(
        width: 50, // Enlarged clickable area
        height: 50,
        point: LatLng(platform.latitude, platform.longitude),
        builder: (ctx) => GestureDetector(
          onTap: () {
            print("🟢 Clicked Platform: ${platform.reference}");
            setState(() {
              _selectedPlatform = platform;
            });

          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.circle, color: _getPlatformColor(platform.status), size: 16.0),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// ✅ Animated pulsing effect for selected platform
  Widget _pulsingSelectedMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: _pulseController.value * 40, // Adjust size dynamically
          height: _pulseController.value * 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purple.withOpacity(0.3),
          ),
        );
      },
    );
  }

  /// ✅ Selected platform marker with pulsing effect
  Marker? _selectedMarker() {
    if (_selectedPlatform == null) return null;

    return Marker(
      width: 50,
      height: 50,
      point: LatLng(_selectedPlatform!.latitude, _selectedPlatform!.longitude),
      builder: (ctx) => Stack(
        alignment: Alignment.center,
        children: [
          _pulsingSelectedMarker(), // ✅ Pulsing blue effect
        ],
      ),
    );
  }

  /// ✅ User's current location (purple pin)
  Marker? _currentLocationMarker() {
    if (_currentLocation == null) return null;

    return Marker(
      width: 50,
      height: 50,
      point: _currentLocation!,
      builder: (ctx) => Icon(Icons.location_on, color: Colors.purple, size: 40.0),
    );
  }

Widget _buildBottomPanel() {
  if (_selectedPlatform == null) return SizedBox.shrink();
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return DraggableScrollableSheet(
    initialChildSize: 0.4, // Default height (30% of screen)
    minChildSize: 0.2, // Minimum height when collapsed
    maxChildSize: 0.9, // Maximum height when expanded
    builder: (context, scrollController) {
      return Container(
        padding: EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {}, // Placeholder for potential tap interaction
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Color.fromARGB(255, 31, 31, 31),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Platform Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color.fromARGB(255, 31, 31, 31),
              ),
            ),
            Divider(color: Colors.white38),
            Expanded(
              child: ListView(
                controller: scrollController, // Enable scrolling when expanded
                children: [
                  _buildInfoRow("Reference", _selectedPlatform!.reference),
                  _buildInfoRow("Model", _selectedPlatform!.model),
                  _buildInfoRow("Network", _selectedPlatform!.network),
                  _buildInfoRow("Status", _selectedPlatform!.status),
                  _buildInfoRow("Latitude", _selectedPlatform!.latitude.toString()),
                  _buildInfoRow("Longitude", _selectedPlatform!.longitude.toString()),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildInfoRow(String label, String value) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDarkMode ? Colors.white70 :  const Color.fromARGB(255, 31, 31, 31), fontSize: 16)),
          Text(value, style: TextStyle(color: isDarkMode ? Colors.white :  const Color.fromARGB(255, 31, 31, 31), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Determine if the app is in dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          (!_isLocationLoaded || !_isBoxInitialized)
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentLocation ?? LatLng(10.0, 20.0),
                    zoom: 6.0,
                  ),
                  children: [
                    // ✅ Switch Tile Layer based on Dark/Light Mode
                    TileLayer(
                      urlTemplate: isDarkMode
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png' // Dark mode tile
                          : 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', // Oceanography basemap
                      subdomains: ['a', 'b', 'c'],
                    ),
                    
                    MarkerLayer(
                      markers: [
                        ..._platformMarkers(),
                        if (_selectedMarker() != null) _selectedMarker()!,
                        if (_currentLocationMarker() != null) _currentLocationMarker()!,
                      ],
                    ),
                  ],
                ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

}
