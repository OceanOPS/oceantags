import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
}

@DriftDatabase(tables: [Platforms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
    latitude: json['latestObs']?['lat']?.toDouble() ?? 0.0,
    longitude: json['latestObs']?['lon']?.toDouble() ?? 0.0,
    status: json['ptfStatus']?['name'] ?? 'Unknown',
    model: json['ptfModel']?['name'] ?? 'Unknown',
    network: json['ptfModel']?['network']?['name'] ?? 'Unknown',
    isFavorite: false, // ✅ Default value
  );
}
