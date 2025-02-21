import 'package:hive/hive.dart';

part 'platform_model.g.dart';

@HiveType(typeId: 0)
class PlatformModel extends HiveObject {
  @HiveField(0)
  String reference;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double longitude;

  @HiveField(3)
  String status;

  @HiveField(4)
  String model;

  @HiveField(5)
  String network;

  @HiveField(6)
  bool isFavorite;

  PlatformModel({
    required this.reference,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.model,
    required this.network,
    this.isFavorite = false,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      reference: json['ref'] ?? 'Unknown',
      latitude: json['latestObs']?['lat']?.toDouble() ?? 0.0, // ✅ Corrected parsing
      longitude: json['latestObs']?['lon']?.toDouble() ?? 0.0, // ✅ Corrected parsing
      status: json['ptfStatus']?['name'] ?? 'Unknown', // ✅ Corrected parsing
      model: json['ptfModel']?['name'] ?? 'Unknown', // ✅ Corrected parsing
      network: json['ptfModel']?['network']?['name'] ?? 'Unknown', // ✅ Corrected parsing
    );
  }
}
