import 'package:hive/hive.dart';
import 'package:game_calendar/features/games/data/entities/game_entity.dart';

part 'game_hive_adapter.g.dart';

@HiveType(typeId: 0)
class GameHiveModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? coverUrl;

  @HiveField(3)
  int? releaseDateMs;

  @HiveField(4)
  String? summary;

  @HiveField(5)
  List<String> screenshots;

  @HiveField(6)
  List<String> videos;

  @HiveField(7)
  double? totalRating;

  @HiveField(8)
  List<int> platformIds;

  @HiveField(9)
  List<int> genreIds;

  GameHiveModel({
    required this.id,
    required this.name,
    this.coverUrl,
    this.releaseDateMs,
    this.summary,
    this.screenshots = const [],
    this.videos = const [],
    this.totalRating,
    this.platformIds = const [],
    this.genreIds = const [],
  });

  GameEntity toEntity() => GameEntity(
        id: id,
        name: name,
        coverUrl: coverUrl,
        releaseDate: releaseDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(releaseDateMs!)
            : null,
        summary: summary,
        screenshots: screenshots,
        videos: videos,
        totalRating: totalRating,
        platformIds: platformIds,
        genreIds: genreIds,
      );

  static GameHiveModel fromEntity(GameEntity e) => GameHiveModel(
        id: e.id,
        name: e.name,
        coverUrl: e.coverUrl,
        releaseDateMs: e.releaseDate?.millisecondsSinceEpoch,
        summary: e.summary,
        screenshots: List.from(e.screenshots),
        videos: List.from(e.videos),
        totalRating: e.totalRating,
        platformIds: List.from(e.platformIds),
        genreIds: List.from(e.genreIds),
      );
}
