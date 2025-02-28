import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'db.g.dart';

@DataClassName('PlatformEntity')
class Platforms extends Table {
  TextColumn get reference => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get status => text()();
  TextColumn get model => text()();
  TextColumn get network => text()();
  BoolColumn get isFavorite => boolean().withDefault(Constant(false))();
  DateTimeColumn get deploymentDate => dateTime().nullable()();
  RealColumn get deploymentLatitude => real().nullable()();
  RealColumn get deploymentLongitude => real().nullable()();
  BoolColumn get unsynced => boolean().withDefault(Constant(true))();
}


@DriftDatabase(tables: [Platforms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ✅ Fetch platforms from API and store in DB
  Future<void> fetchAndStorePlatforms() async {
    try {
      String formattedDate = DateTime.now()
          .toUtc()
          .subtract(Duration(days: 180))
          .toString()
          .split('.')[0];

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
            "ptfModel.network.name",
            "ptfDepl.lat",
            "ptfDepl.lon"
          ])
        },
      );

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> platformsData = jsonResponse['data'];

        await clearPlatforms(); // ✅ Clear old data before inserting

        for (var platformJson in platformsData) {
          var platform = platformFromJson(platformJson);
          await insertPlatform(platform);
        }
      } else {
        throw Exception("Failed to load platforms (Status ${response.statusCode})");
      }
    } catch (error) {
      print("❌ Error fetching data: $error");
    }
  }

  // ✅ Insert a platform
  Future<void> insertPlatform(PlatformEntity platform) =>
      into(platforms).insert(platform, mode: InsertMode.insertOrReplace);

  // ✅ Get all platforms
  Future<List<PlatformEntity>> getAllPlatforms() => select(platforms).get();

  // ✅ Get platforms by search query
  Future<List<PlatformEntity>> searchPlatforms(String query) {
    final lowerQuery = query.toLowerCase();

    return (select(platforms)
          ..where((p) => p.reference.lower().contains(lowerQuery) |
              p.model.lower().contains(lowerQuery) |
              p.network.lower().contains(lowerQuery) |
              p.status.lower().contains(lowerQuery)))
        .get();
  }


  // ✅ Toggle favorite
  Future<void> toggleFavorite(String reference, bool isFavorite) {
    return (update(platforms)
          ..where((p) => p.reference.equals(reference)))
        .write(PlatformsCompanion(isFavorite: Value(isFavorite)));
  }

  // ✅ Clear all platforms
  Future<void> clearPlatforms() => delete(platforms).go();

  Future<PlatformEntity?> getPlatformByReference(String reference) {
    return (select(platforms)..where((p) => p.reference.equals(reference))).getSingleOrNull();
  }

  // ✅ Update Deployment Details & Mark as Unsynced
  Future<void> updateDeployment(String reference, {double? lat, double? lon, bool? unsynced}) {
    return (update(platforms)..where((p) => p.reference.equals(reference)))
        .write(PlatformsCompanion(
          deploymentDate: Value(DateTime.now()), // ✅ Always update time
          deploymentLatitude: lat != null ? Value(lat) : const Value.absent(), // ✅ Allow null
          deploymentLongitude: lon != null ? Value(lon) : const Value.absent(), // ✅ Allow null
          unsynced: unsynced != null ? Value(unsynced) : const Value.absent(), // ✅ Allow null
        ));
  }



}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'platforms.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

PlatformEntity platformFromJson(Map<String, dynamic> json) {
  return PlatformEntity(
    reference: json['ref'] ?? 'Unknown',
    latitude: (json['latestObs']?['lat'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['latestObs']?['lon'] as num?)?.toDouble() ?? 0.0,
    status: json['ptfStatus']?['name'] ?? 'Unknown',
    model: json['ptfModel']?['name'] ?? 'Unknown',
    network: json['ptfModel']?['network']?['name'] ?? 'Unknown',
    isFavorite: false,
    deploymentDate: json['ptfDepl']?['deplDate'] != null
        ? DateTime.tryParse(json['ptfDepl']['deplDate']) 
        : null,  // ✅ Corrected reference & safe parsing
    deploymentLatitude: (json['ptfDepl']?['lat'] as num?)?.toDouble(), // ✅ Safe conversion
    deploymentLongitude: (json['ptfDepl']?['lon'] as num?)?.toDouble(),
    unsynced: json['unsynced'] ?? false,
  );
}



