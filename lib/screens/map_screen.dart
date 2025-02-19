import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'dart:async';
import '../platform_model.dart';
import 'dart:math';
import 'dart:ui' as ui; // Explicitly import dart:ui for drawing paths
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';


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

    // ✅ Listen to zoom changes
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {}); // 🔄 Rebuild UI when zoom changes
      }
    });

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

    // override for demo !!!
    setState(() {
      _currentLocation = LatLng(42.7, 3.25);
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

  List<Widget> _buildRegularPlatformMarker(PlatformModel platform) {
    return [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getPlatformColor(platform.status),
        ),
      ),
    ];
  }

List<Widget> _buildHighlightedPlatformMarker(PlatformModel platform) {
  return [
    // 🟢 Outer Colored Border (Depends on Status)
    Container(
      width: 54, // Slightly larger than the main container
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent, // Ensures only border is visible
        border: Border.all(color: _getPlatformColor(platform.status), width: 2), // Thin colored border
      ),
      child: Center( // Center the main white-bordered container
        child: Container(
          width: 50, // Main white circular border
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 5), // Thick white border
          ),
          child: ClipOval(
            child: Image.asset(
              _getNetworkImage(platform.network), // Dynamically select image
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ),

    // 🔻 Short Stubby Line Below Circle (Now More Visible)
    Positioned(
      bottom: -14, // Adjusted position for better visibility
      child: Container(
        width: 3, // Thin line
        height: 12, // Slightly longer
        decoration: BoxDecoration(
          color: _getPlatformColor(platform.status), // Now colored like status
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),

    // 🎯 Platform Color Dot (Exactly on Platform Location)
    Positioned(
      bottom: -20, // Ensures it aligns with platform location
      child: Container(
        width: 12, // Small dot
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getPlatformColor(platform.status), // Platform status color
          border: Border.all(color: Colors.white, width: 2), // Thin white border
        ),
      ),
    ),
  ];
}


String _getNetworkImage(String network) {
  Map<String, String> networkImages = {
    'argo': 'assets/images/argo.png',
    'dbcp': 'assets/images/mooring.jpg',
    'oceansites': 'assets/images/mooring.png',
    'sot': 'assets/images/vos.jpg',
    'oceangliders': 'assets/images/glider.png',
    'anibos': 'assets/images/wave.png',
  };

  return networkImages[network.toLowerCase()] ?? 'assets/images/default.png';
}


  List<Marker> _platformMarkers() {
    if (!_isBoxInitialized || _platformBox == null || _platformBox!.isEmpty) return [];

    double zoomLevel = 9.0; // Default zoom in case _mapController isn't ready
    try {
      zoomLevel = _mapController.camera.zoom; // ✅ Get the current zoom level
    } catch (e) {
      print("⚠️ _mapController.zoom not ready yet: $e");
    }

    bool showHighlighted = zoomLevel >= 9; // ✅ Show highlighted markers at zoom 10+

    return _platformBox!.values.map((platform) {
      return Marker(
        width: showHighlighted ? 80 : 16,
        height: showHighlighted ? 100 : 16,
        point: LatLng(platform.latitude, platform.longitude),
        child: GestureDetector(
          onTap: () {
            print("🟢 Clicked Platform: ${platform.reference}");
            setState(() {
              _selectedPlatform = platform;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: showHighlighted 
              ? _buildHighlightedPlatformMarker(platform) 
              : _buildRegularPlatformMarker(platform),
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
    child: Stack(
      alignment: Alignment.center,
      children: [
        _pulsingSelectedMarker(), // ✅ Pulsing blue effect
      ],
    ),
  );

  }

  /// ✅ User's current location (pink 3D pin)
  Marker? _currentLocationMarker() {
    if (_currentLocation == null) return null;

    return Marker(
      width: 50,
      height: 80, // Adjusted height for pin + line
      point: _currentLocation!,
      child: Column(
        children: [
          // 🎯 Round Pink Sphere with Reflection Effect
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 224, 93, 145),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // ✨ Oval White Reflection (Moved to Top Left)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 10,
                    height: 7, // Slightly oval for realism
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6), // Semi-transparent for reflection
                    ),
                  ),
                ),

                // ✨ Soft Glow Reflection
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    width: 16,
                    height: 10, // Larger and diffused
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2), // Fainter outer glow
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📍 Thinner & Shorter Vertical Line (⅔ of sphere’s diameter)
          Container(
            width: 2, // Made thinner
            height: 21, // ⅔ of 32px diameter
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 224, 93, 145),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          // ⚫ Small Black Oval (3D Hole Effect)
          Container(
            width: 8, // Wider than tall for an oval effect
            height: 3, // Very thin
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.black.withOpacity(0.7), // Slight transparency for depth effect
              borderRadius: BorderRadius.circular(2), // Slight rounding for realism
            ),
          ),
        ],
      ),
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

/// 📍 Recenter map on user and zoom in
void _recenterOnUser() {
  if (_currentLocation != null) {
    _mapController.move(_currentLocation!, 10); // Zoom level 10
  }
}

/// 🧭 Reset map rotation to North
void _resetToNorth() {
  _mapController.rotate(0); // Reset rotation to 0 degrees (north)
}

  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
    loadingStrategy: BrowseLoadingStrategy.cacheFirst,
  );

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
                    initialCenter: _currentLocation ?? LatLng(10.0, 20.0),
                    initialZoom: 10.0,
                  ),
                  children: [
                    // ✅ Switch Tile Layer based on Dark/Light Mode
                    TileLayer(
                      tileProvider: _tileProvider,
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
                // 📍 Target Button (Recenter on User Location)
                Positioned(
                  bottom: 40, // Adjust placement
                  right: 10,
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    onPressed: _recenterOnUser,
                    child: Icon(Icons.my_location, color: Colors.black),
                  ),
                ),

                // 🧭 Compass Button (Reset to North)
                Positioned(
                  bottom: 100,
                  right: 10,
                  child: FloatingActionButton(
                    heroTag: "btn2",
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    onPressed: _resetToNorth,
                    child: Icon(Icons.explore, color: Colors.black), // Compass icon
                  ),
                )
                ,
          _buildBottomPanel(),
        ],
      ),
    );
  }

}
