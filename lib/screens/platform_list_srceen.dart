import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../platform_model.dart';
import 'platform_detail_screen.dart';

class PlatformListScreen extends StatefulWidget {
  @override
  _PlatformListScreenState createState() => _PlatformListScreenState();
}

class _PlatformListScreenState extends State<PlatformListScreen> {
  late Box<PlatformModel> _platformBox;
  List<PlatformModel> filteredPlatforms = [];
  TextEditingController searchController = TextEditingController();
  bool _isFetching = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  void _filterPlatforms() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPlatforms = _platformBox.values.where((platform) {
        return platform.reference.toLowerCase().contains(query) ||
               platform.model.toLowerCase().contains(query) ||
               platform.network.toLowerCase().contains(query) ||
               platform.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addDummyPlatforms() {
    setState(() {
      filteredPlatforms = _platformBox.values.toList();
    });
  }

  Future<void> _initializeBox() async {
    await Hive.deleteBoxFromDisk('platforms'); // ✅ Reset Hive to remove corrupted data
    _platformBox = await Hive.openBox<PlatformModel>('platforms');
    setState(() {}); // Met à jour l'interface
    await _fetchPlatformData();
    filteredPlatforms = _platformBox.values.toList();
    searchController.addListener(_filterPlatforms);
    setState(() {
      filteredPlatforms = _platformBox.values.toList();
    });
  }

  Future<void> _fetchPlatformData() async {
    try {
      String formattedDate = DateTime.now().toUtc().subtract(Duration(days: 180)).toString().split('.')[0];

      Uri apiUrl = Uri.parse("https://www.ocean-ops.org/api/1/data/platform/").replace(
        queryParameters: {
          "exp": jsonEncode([
            "ptfStatus.name in ('INACTIVE','CLOSED','OPERATIONAL') and latestObs.obsDate>'$formattedDate'"
          ]),
          "include": jsonEncode([
            "ref",
            "latestObs.lat",
            "latestObs.lon",
            "latestObs.obsDate",
            "ptfStatus.name",
            "ptfDepl.deplDate",
            "ptfModel.name",
            "ptfModel.network.name"
          ])
        },
      );

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> platformsData = jsonResponse['data'];

        await _platformBox.clear(); // ✅ Clear old data

        for (var platformJson in platformsData) {
          var platform = PlatformModel.fromJson(platformJson);
          _platformBox.add(platform);
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

  // 🔹 Nouvelle méthode : Ouvrir les détails de la plateforme
  void _openPlatformDetails(PlatformModel platform) {
    print("Clicked on ${platform.reference}");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => PlatformDetailScreen(platform: platform)),
    // );
  }

  void _toggleFavorite(PlatformModel platform) {
    setState(() {
      platform.isFavorite = !platform.isFavorite;
      platform.save(); // Sauvegarde la modification dans Hive
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

  // Fonction pour obtenir la couleur du statut
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

  Widget _buildPlatformCard(PlatformModel platform) {
    return GestureDetector( // Ajout du clic
      onTap: () => _openPlatformDetails(platform), // 🔹 Navigue vers les détails
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row( // Utilisation d'un Row pour aligner l'image et le texte
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Image à gauche
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Arrondi pour un look moderne
                child: Image.asset(
                  _getNetworkImage(platform.network), // Chemin du fichier local
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12), // Espace entre l'image et le texte
              
              Expanded(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Nom + Favoris bien alignés
                  Row(
                    // mainAxisSize: MainAxisSize.min, // Ajouté pour éviter que l'icône prenne trop d'espace
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

                  // 🔹 Localisation avec icône
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                      SizedBox(width: 6),
                      Text("${platform.latitude};${platform.longitude}", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(height: 6),
                  
                  Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.blueAccent, size: 20),
                      SizedBox(width: 6),
                      Text(
                        platform.network, 
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                  SizedBox(height: 6),
                  
                  Row(
                    children: [
                      Icon(Icons.branding_watermark, color: Colors.orange, size: 20),
                      SizedBox(width: 6),
                      Text(
                        platform.model, 
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                  // SizedBox(height: 6),
                ],
              ),
              ),
              // ✅ Statut bien aligné en bas à droite
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 50), // 🔹 Pousse le statut vers le bas
                _buildStatusBadge(platform.status),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Badge de statut
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
      appBar: AppBar(title: Text("Liste des plateformes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Rechercher...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _platformBox.listenable(),
              builder: (context, Box<PlatformModel> box, _) {
                final platforms = searchController.text.isEmpty
                    ? box.values.toList()
                    : filteredPlatforms;
                return ListView.builder(
                  itemCount: platforms.length,
                  itemBuilder: (context, index) {
                    return _buildPlatformCard(platforms[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Custom DataSource for Lazy Loading
class _PlatformDataSource extends DataTableSource {
  final Box<PlatformModel> _box;

  _PlatformDataSource(this._box);

  @override
  DataRow getRow(int index) {
    if (index >= _box.length) return DataRow(cells: []);

    final platform = _box.getAt(index);
    return DataRow(cells: [
      DataCell(Text(platform?.reference ?? '')),
      DataCell(Text(platform?.latitude.toStringAsFixed(2) ?? '')),
      DataCell(Text(platform?.longitude.toStringAsFixed(2) ?? '')),
      DataCell(Text(platform?.status ?? '')),
      DataCell(Text(platform?.model ?? '')),
      DataCell(Text(platform?.network ?? '')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _box.length;

  @override
  int get selectedRowCount => 0;
}
