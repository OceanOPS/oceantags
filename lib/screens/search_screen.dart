import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/db.dart';
import 'platform_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final AppDatabase database;

  const SearchScreen({Key? key, required this.database}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late AppDatabase _db;
  List<PlatformEntity> filteredPlatforms = [];
  TextEditingController searchController = TextEditingController();
  bool _isFetching = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _db = widget.database;
    searchController.addListener(_filterPlatforms);
    _filterPlatforms();
  }

  void _filterPlatforms() async {
    String query = searchController.text.toLowerCase();
    List<PlatformEntity> results = await _db.searchPlatforms(query);

    setState(() {
      filteredPlatforms = results;
    });
  }

void _openPlatformDetails(PlatformEntity platform) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PlatformDetailScreen(
        platform: platform, 
        database: widget.database,
        onPlatformUpdated: _filterPlatforms, // ✅ Pass the refresh function
      ),
    ),
  );
}


  void _toggleFavorite(PlatformEntity platform) async {
    final updatedPlatform = platform.copyWith(isFavorite: !platform.isFavorite);
    await _db.toggleFavorite(platform.reference, updatedPlatform.isFavorite);

    setState(() {
      filteredPlatforms = filteredPlatforms.map((p) {
        return p.reference == platform.reference ? updatedPlatform : p;
      }).toList();
    });
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

  Widget _buildStatusBadge(String status) {
    return Positioned(
      top: 2,
      left: 2,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _getStatusColor(status),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Subtle shadow
              blurRadius: 4, // Soft blur
              spreadRadius: 2, // Extends the shadow
              offset: Offset(0, 2), // Positioned slightly below
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformList(PlatformEntity platform) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // ✅ Ajout du padding left/right
          child: ListTile(
            leading: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    _getNetworkImage(platform.network),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                _buildStatusBadge(platform.status),
              ],
            ),
            title: Text(
              platform.reference,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              platform.model,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: GestureDetector(
              onTap: () => _toggleFavorite(platform),
              child: Icon(
                platform.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: platform.isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => _openPlatformDetails(platform),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          height: 0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search...",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlatforms.length,
              itemBuilder: (context, index) => _buildPlatformList(filteredPlatforms[index]),
            ),
          ),
        ],
      ),
    );
  }
}
