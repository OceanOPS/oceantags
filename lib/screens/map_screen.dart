import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import '../database/db.dart'; 


class MapScreen extends StatefulWidget {
  final AppDatabase database; 

  const MapScreen({Key? key, required this.database}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  bool _isLocationLoaded = false;
  bool _isBoxInitialized = false;
  List<PlatformEntity> _platforms = [];
  bool _downloading = false;
  double _downloadProgress = 0.0;
  String _downloadMessage = "";
  bool _menuExpanded = false; 

  void _toggleMenu() {
    setState(() {
      _menuExpanded = !_menuExpanded;
    });
  }

  PlatformEntity? _selectedPlatform;
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
      final platforms = await widget.database.getAllPlatforms(); // ✅ Fetch from Drift
      setState(() {
        _platforms = platforms; // ✅ Store fetched platforms
        _isBoxInitialized = true; // ✅ Mark as initialized
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

List<Widget> _buildRegularPlatformMarker(PlatformEntity platform) {
  double zoomLevel = 9.0; // Default zoom level
  try {
    zoomLevel = _mapController.camera.zoom; // ✅ Get current zoom
  } catch (e) {
    print("⚠️ _mapController.zoom not ready yet: $e");
  }

  // ✅ Scale dot size dynamically (min 4px, max 12px)
  double size = zoomLevel >= 10 ? 12 : (zoomLevel * 1.2).clamp(4, 12);

  return [
    Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPlatformColor(platform.status), // ✅ Uses Drift model
      ),
    ),
  ];
}


List<Widget> _buildHighlightedPlatformMarker(PlatformEntity platform) {
  return [
    // 📍 PNG Map Marker Positioned Correctly
    Positioned(
      bottom: 40, // Ensures bottom center aligns with location
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔹 Custom PNG Marker with Transparent Hole
          Image.asset(
            "assets/images/map-marker.png", // ✅ PNG marker
            width: 50, // Adjust size to match existing design
            height: 70,
          ),

          // 🔹 Inner Circle for Platform Network Image
          Positioned(
            top: 12, // Adjusted to fit the round space
            child: Container(
              width: 35, // Size to fit inside the hole
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Background in case no image
                border: Border.all(color: Colors.white, width: 2), // White border around image
              ),
              child: ClipOval(
                child: Image.asset(
                  _getNetworkImage(platform.network), // ✅ Platform Network Image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

        ],
      ),
    ),
  ];
}


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

  List<Marker> _platformMarkers() {
    if (_platforms.isEmpty) return [];

    double zoomLevel = 9.0; // Default zoom in case _mapController isn't ready
    try {
      zoomLevel = _mapController.camera.zoom; // ✅ Get the current zoom level
    } catch (e) {
      print("⚠️ _mapController.zoom not ready yet: $e");
    }

    bool showHighlighted = zoomLevel >= 7; // ✅ Show highlighted markers at zoom 10+

     return _platforms.map((platform) {
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
          width: _pulseController.value * 40,
          height: _pulseController.value * 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
        _pulsingSelectedMarker(),
      ],
    ),
  );

  }

  /// ✅ User's current location (pink 3D pin)
  Marker? _currentLocationMarker() {
    if (_currentLocation == null) return null;

    double zoomLevel = 9.0; // Default zoom level
    try {
      zoomLevel = _mapController.camera.zoom; // ✅ Get current zoom
    } catch (e) {
      print("⚠️ _mapController.zoom not ready yet: $e");
    }

    bool showFullPin = zoomLevel >= 8; // ✅ Show full pin only if zoom ≥ 8

    return Marker(
      width: showFullPin ? 50 : 12,
      height: showFullPin ? 88 : 12,
      point: _currentLocation!,
      child: showFullPin
          ? Stack(
              alignment: Alignment.center,
              children: [
                if (_selectedPlatform == null || _selectedPlatform == _currentLocationPlatform())
                  _pulsingSelectedMarker(), // ✅ Default selection is user's location
                _build3DPin(), // ✅ Original pink sphere + line
              ],
            )
          : _buildSmallDot(), // ✅ Switch to small dot when zoomed out
    );
  }

  /// ✅ **User's Location is a Default "Platform"**
  PlatformEntity _currentLocationPlatform() {
    return PlatformEntity(
      reference: "User Location",
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      status: "Active",
      model: "GPS",
      network: "Self",
      isFavorite: false,
    );
  }

  /// ✅ **Original Pink Sphere & Line**
  Widget _build3DPin() {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 201, 171, 233),
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
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 10,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 16,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 17,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 201, 171, 233),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// ✅ **Small Dot for Low Zoom Levels**
  Widget _buildSmallDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 201, 171, 233), // Same color as pin
      ),
    );
  }



  Widget _buildBottomPanel() {
    if (_selectedPlatform == null) return SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Align( 
                        alignment: Alignment.center,
                        child: Container(
                          width: 60, 
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Platform Details",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.primary),
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
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  StreamSubscription<DownloadProgress>? _progressSubscription; // ✅ Store the subscription

  void _downloadDisplayedRegion() async {
    if (_downloading) return; // ✅ Prevent duplicate downloads

    // ✅ Cancel the previous subscription before starting a new one
    await _progressSubscription?.cancel();
    _progressSubscription = null;

    setState(() {
      _downloading = true;
      _downloadProgress = 0.0;
      _downloadMessage = "Downloading displayed region at all zoom levels - 0%";
    });

    final LatLngBounds displayedBounds = _mapController.camera.visibleBounds;

    final region = RectangleRegion(displayedBounds);

    final downloadableRegion = region.toDownloadable(
      minZoom: 0, // ✅ Fixed minimum zoom level
      maxZoom: 15, // ✅ Fixed maximum zoom level
      options: TileLayer(
        tileProvider: _tileProvider, // ✅ Use same tile provider as displayed map
        urlTemplate: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', // Oceanography basemap
        subdomains: ['a', 'b', 'c'],
        userAgentPackageName: 'com.example.oceantrack',
      ),
    );

    try {
      final downloadTask = FMTCStore('mapStore').download.startForeground(
        region: downloadableRegion,
        instanceId: DateTime.now().millisecondsSinceEpoch, // ✅ Unique ID for each download
        parallelThreads: 5,
        maxBufferLength: 200,
        skipExistingTiles: true,
        skipSeaTiles: true,
        maxReportInterval: const Duration(seconds: 1),
        retryFailedRequestTiles: true,
      );

      // ✅ Convert the stream to a broadcast stream to allow multiple listeners
      StreamController<DownloadProgress> progressController = StreamController.broadcast();
      downloadTask.downloadProgress.listen((event) => progressController.add(event));

      Stream<DownloadProgress> downloadProgress = progressController.stream;

      // ✅ Listen to progress updates, ensuring only one active listener
      _progressSubscription = downloadProgress.listen((progress) {
        if (progress.maxTilesCount > 0) {
          setState(() {
            _downloadProgress = progress.percentageProgress / 100;
            _downloadMessage =
                "Downloading displayed region basemap at all zoom levels - ${progress.percentageProgress.toStringAsFixed(1)}%";
          });
        }

        if (progress.percentageProgress == 100) {
          setState(() {
            _downloadProgress = progress.percentageProgress / 100;
            _downloadMessage =
                "Displayed map region successfully saved to cache!";
          });
        }
      });

      await downloadProgress.last; // ✅ Wait until download completes
      await _progressSubscription?.cancel(); // ✅ Cancel stream after completion
      await progressController.close(); // ✅ Close the controller to prevent memory leaks

      setState(() {
        _downloading = false;
        _downloadMessage = "";
      });

    } catch (e) {
      setState(() {
        _downloading = false;
        _downloadMessage = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  /// ✅ **M3-Style Floating Menu**
  Widget _buildMenu() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: _menuExpanded ? 28 : 18,
      right: 14,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "menuButton",
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            onPressed: () {
              setState(() => _menuExpanded = !_menuExpanded);
            },
            child: Icon(Icons.tune_rounded, size: 40),
          ),
          if (_menuExpanded) ...[
            _buildMenuItem(Icons.download, "Download Map", _downloadDisplayedRegion),
            _buildMenuItem(Icons.explore, "Reset North", _resetToNorth),
            _buildMenuItem(Icons.my_location, "Recenter", _recenterOnUser),
          ],
        ],
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {

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
                      urlTemplate: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', // Oceanography basemap
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
           

                // ✅ Show Download Progress Bar
                if (_downloading)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          _downloadMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(value: _downloadProgress),
                      ],
                    ),
                  ),

                  
              // ✅ Floating M3 Menu Button
              _buildMenu(),

              // ✅ M3 Adaptive Bottom Panel
              _buildBottomPanel(),
                
        ],
      ),
    );
  }

  /// ✅ **Reusable M3 Menu Button**
  Widget _buildMenuItem(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: FloatingActionButton.small(
        heroTag: tooltip,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        onPressed: () {
          setState(() => _menuExpanded = false);
          onPressed();
        },
        tooltip: tooltip,
        child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

}
