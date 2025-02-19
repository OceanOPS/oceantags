import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../platform_model.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  late Box<PlatformModel> _platformBox;
  bool _isFetching = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    await Hive.deleteBoxFromDisk('platforms'); // ✅ Reset Hive to remove corrupted data
    _platformBox = await Hive.openBox<PlatformModel>('platforms');
    await _fetchPlatformData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Platform Data')),
      body: _isFetching
          ? Center(child: CircularProgressIndicator()) // ✅ Show loading indicator
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // ✅ Show error message if request failed
              : ValueListenableBuilder(
                  valueListenable: _platformBox.listenable(),
                  builder: (context, Box<PlatformModel> box, _) {
                    if (box.isEmpty) {
                      return Center(child: Text('No platform data available'));
                    }

                    return SingleChildScrollView(
                      child: PaginatedDataTable(
                        header: Text('Platform Data'),
                        rowsPerPage: 50, // ✅ Show 50 rows per page
                        columns: const [
                          DataColumn(label: Text('Reference')),
                          DataColumn(label: Text('Latitude')),
                          DataColumn(label: Text('Longitude')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Model')),
                          DataColumn(label: Text('Network')),
                        ],
                        source: _PlatformDataSource(box),
                      ),
                    );
                  },
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
