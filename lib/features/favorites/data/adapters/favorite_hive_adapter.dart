import 'package:hive/hive.dart';

part 'favorite_hive_adapter.g.dart';

@HiveType(typeId: 1)
class FavoriteHiveModel extends HiveObject {
  @HiveField(0)
  int gameId;

  @HiveField(1)
  int addedAtMs;

  FavoriteHiveModel({
    required this.gameId,
    required this.addedAtMs,
  });
}
