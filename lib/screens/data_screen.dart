import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../platform_model.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  late Box<PlatformModel> _platformBox;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _platformBox = await Hive.openBox<PlatformModel>('platforms');
    _populateDemoData(); // Optional: Prepopulate data for the demo
    setState(() {});
  }

  Future<void> _populateDemoData() async {
    // Clear the box to reset the data
    await _platformBox.clear();

    if (_platformBox.isEmpty) {
      final demoData = List.generate(
        10,
        (index) {
          // Define ranges for sea areas around Europe
          final latitudes = [
            [54.0, 59.0], // North Sea
            [48.5, 51.5], // English Channel
            [38.0, 43.0], // Mediterranean Sea
          ];

          final longitudes = [
            [5.0, 8.0],   // North Sea
            [-5.0, 1.0],   // English Channel
            [0.0, 25.0],   // Mediterranean Sea
          ];

          // Select a random sea area
          final seaIndex = index % latitudes.length;

          // Generate random latitude and longitude within the range
          final latRange = latitudes[seaIndex];
          final lonRange = longitudes[seaIndex];
          final latitude = latRange[0] + (latRange[1] - latRange[0]) * (index / 20);
          final longitude = lonRange[0] + (lonRange[1] - lonRange[0]) * (index / 20);

          return PlatformModel(
            reference: 'REF${index.toString().padLeft(3, '0')}',
            latitude: latitude,
            longitude: longitude,
          );
        },
      );

      for (var platform in demoData) {
        await _platformBox.add(platform);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Platform Data'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _platformBox.listenable(),
        builder: (context, Box<PlatformModel> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return SingleChildScrollView( // Enable vertical scrolling
            child: SingleChildScrollView( // Enable horizontal scrolling
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('Latitude')),
                  DataColumn(label: Text('Longitude')),
                ],
                rows: box.values.map((platform) {
                  return DataRow(cells: [
                    DataCell(Text(platform.reference)),
                    DataCell(Text(platform.latitude.toStringAsFixed(2))),
                    DataCell(Text(platform.longitude.toStringAsFixed(2))),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
