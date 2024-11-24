import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../platform_model.dart'; // Ensure your PlatformModel is imported

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  bool _isLoading = true;
  late Box<PlatformModel> _platformBox;

  @override
  void initState() {
    super.initState();
    _initializePlatformData();
    _getCurrentLocation();
  }

  Future<void> _initializePlatformData() async {
    _platformBox = await Hive.openBox<PlatformModel>('platforms');
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Check for location permissions
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

    // Fetch the current location
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _currentLocation ?? LatLng(10.0, 20.0),
                zoom: 4.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        builder: (ctx) => Icon(
                          Icons.location_on,
                          color: const Color.fromARGB(255, 156, 9, 201),
                          size: 40.0,
                        ),
                      ),
                    ..._platformMarkers(),
                  ],
                ),
              ],
            ),
    );
  }

  List<Marker> _platformMarkers() {
    if (_platformBox.isEmpty) return [];
    return _platformBox.values.map((platform) {
      return Marker(
        point: LatLng(platform.latitude, platform.longitude),
        builder: (ctx) => Icon(
          Icons.circle,
          color: Colors.blue,
          size: 10.0,
        ),
      );
    }).toList();
  }
}
