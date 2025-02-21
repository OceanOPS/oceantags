// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlatformModelAdapter extends TypeAdapter<PlatformModel> {
  @override
  final int typeId = 0;

  @override
  PlatformModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlatformModel(
      reference: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      status: fields[3] as String,
      model: fields[4] as String,
      network: fields[5] as String,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlatformModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.reference)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.network)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
