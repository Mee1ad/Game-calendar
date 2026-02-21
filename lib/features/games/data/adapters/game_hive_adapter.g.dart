// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'game_hive_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameHiveModelAdapter extends TypeAdapter<GameHiveModel> {
  @override
  final int typeId = 0;

  @override
  GameHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameHiveModel(
      id: fields[0] as int,
      name: fields[1] as String,
      coverUrl: fields[2] as String?,
      releaseDateMs: fields[3] as int?,
      summary: fields[4] as String?,
      screenshots: (fields[5] as List?)?.cast<String>() ?? const [],
      videos: (fields[6] as List?)?.cast<String>() ?? const [],
      totalRating: fields[7] as double?,
      platformIds: (fields[8] as List?)?.cast<int>() ?? const [],
      genreIds: (fields[9] as List?)?.cast<int>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, GameHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.coverUrl)
      ..writeByte(3)
      ..write(obj.releaseDateMs)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.screenshots)
      ..writeByte(6)
      ..write(obj.videos)
      ..writeByte(7)
      ..write(obj.totalRating)
      ..writeByte(8)
      ..write(obj.platformIds)
      ..writeByte(9)
      ..write(obj.genreIds);
  }
}
