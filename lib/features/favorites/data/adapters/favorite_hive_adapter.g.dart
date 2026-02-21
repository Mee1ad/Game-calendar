// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'favorite_hive_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteHiveModelAdapter extends TypeAdapter<FavoriteHiveModel> {
  @override
  final int typeId = 1;

  @override
  FavoriteHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteHiveModel(
      gameId: fields[0] as int,
      addedAtMs: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.addedAtMs);
  }
}
