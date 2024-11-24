import 'package:hive/hive.dart';

part 'platform_model.g.dart'; // Generated file

@HiveType(typeId: 0) // Unique type ID for this model
class PlatformModel {
  @HiveField(0)
  late String reference;

  @HiveField(1)
  late double latitude;

  @HiveField(2)
  late double longitude;

  PlatformModel({required this.reference, required this.latitude, required this.longitude});
}
