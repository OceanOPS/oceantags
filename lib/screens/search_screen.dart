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
    _fetchPlatformData();
  }

  Future<void> _fetchPlatformData() async {
    setState(() {
      _isFetching = true;
      _errorMessage = '';
    });

    try {
      String formattedDate = DateTime.now().toUtc().subtract(Duration(days: 180)).toString().split('.')[0];

      Uri apiUrl = Uri.parse("https://www.ocean-ops.org/api/1/data/platform/").replace(
        queryParameters: {
          "exp": jsonEncode(["ptfStatus.name in ('INACTIVE','CLOSED','OPERATIONAL') and latestObs.obsDate>'$formattedDate'"]),
          "include": jsonEncode(["ref", "latestObs.lat", "latestObs.lon", "latestObs.obsDate", "ptfStatus.name", "ptfDepl.deplDate", "ptfModel.name", "ptfModel.network.name"])
        },
      );

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> platformsData = jsonResponse['data'];

        await _db.clearPlatforms(); // ✅ Clear old data before inserting

        for (var platformJson in platformsData) {
          var platform = platformFromJson(platformJson);
          await _db.insertPlatform(platform);
        }

        setState(() {
          _isFetching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data (Status ${response.statusCode})';
          _isFetching = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching data: $error';
        _isFetching = false;
      });
    }
  }

  void _filterPlatforms() async {
    String query = searchController.text.toLowerCase();
    List<PlatformEntity> results = await _db.searchPlatforms(query);

    setState(() {
      filteredPlatforms = results;
    });
  }

  void _openPlatformDetails(PlatformEntity platform) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlatformDetailScreen(platform: platform)),
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

  Widget _buildPlatformCard(PlatformEntity platform) {
    return GestureDetector(
      onTap: () => _openPlatformDetails(platform),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _getNetworkImage(platform.network),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleFavorite(platform),
                          child: Icon(
                            platform.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: platform.isFavorite ? Colors.red : Colors.grey,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            platform.reference,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                        SizedBox(width: 6),
                        Text("${platform.latitude};${platform.longitude}", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 6),
                        Text(
                          platform.network,
                          style: TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.branding_watermark, color: Colors.orange, size: 20),
                        SizedBox(width: 6),
                        Text(
                          platform.model,
                          style: TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50),
                  _buildStatusBadge(platform.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlatforms.length,
              itemBuilder: (context, index) => _buildPlatformCard(filteredPlatforms[index]),
            ),
          ),
        ],
      ),
    );
  }
}
