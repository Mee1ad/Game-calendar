import 'package:game_calendar/features/games/domain/models/game.dart';

class GameEntity {
  GameEntity({
    required this.id,
    required this.name,
    this.coverUrl,
    this.releaseDate,
    this.summary,
    this.screenshots = const [],
    this.videos = const [],
    this.totalRating,
    this.platformIds = const [],
    this.genreIds = const [],
  });

  final int id;
  final String name;
  final String? coverUrl;
  final DateTime? releaseDate;
  final String? summary;
  final List<String> screenshots;
  final List<String> videos;
  final double? totalRating;
  final List<int> platformIds;
  final List<int> genreIds;

  Game toDomain() => Game(
        id: id,
        name: name,
        coverUrl: coverUrl,
        releaseDate: releaseDate,
        summary: summary,
        screenshots: screenshots,
        videos: videos,
        totalRating: totalRating,
        platformIds: platformIds,
        genreIds: genreIds,
      );

  factory GameEntity.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    final cover = json['cover'];
    if (cover is Map && cover['url'] != null) {
      var url = cover['url'].toString();
      if (url.startsWith('//')) {
        url = 'https:$url';
      } else if (!url.startsWith('http')) {
        url = 'https://images.igdb.com/igdb/image/upload/$url';
      }
      coverUrl = url
          .replaceAll('t_thumb', 't_720p')
          .replaceAll('t_cover_big', 't_720p');
    }

    DateTime? releaseDate;
    final ts = json['first_release_date'];
    if (ts != null) {
      releaseDate = DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000);
    }

    final screenshotsRaw = json['screenshots'];
    final screenshots = screenshotsRaw is List
        ? (screenshotsRaw)
            .whereType<Map>()
            .map((e) {
              final u = e['url'];
              if (u == null) return null;
              var s = u.toString();
              if (s.startsWith('//')) {
                s = 'https:$s';
              } else if (!s.startsWith('http')) {
                s = 'https://images.igdb.com/igdb/image/upload/$s';
              }
              return s.replaceAll('t_thumb', 't_screenshot_big');
            })
            .whereType<String>()
            .toList()
        : <String>[];

    final videosRaw = json['videos'];
    final videos = videosRaw is List
        ? (videosRaw)
            .whereType<Map>()
            .map((e) => e['video_id']?.toString())
            .whereType<String>()
            .map((id) => 'https://www.twitch.tv/videos/$id')
            .toList()
        : <String>[];

    double? totalRating;
    final r = json['total_rating'];
    if (r != null) totalRating = (r as num).toDouble();

    final platformsRaw = json['platforms'];
    final platformIds = platformsRaw is List
        ? (platformsRaw)
            .map((e) => e is int ? e : (e is Map ? e['id'] : null))
            .whereType<int>()
            .toList()
        : <int>[];

    final genresRaw = json['genres'];
    final genreIds = genresRaw is List
        ? (genresRaw)
            .map((e) => e is int ? e : (e is Map ? e['id'] : null))
            .whereType<int>()
            .toList()
        : <int>[];

    return GameEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      coverUrl: coverUrl,
      releaseDate: releaseDate,
      summary: json['summary'] as String?,
      screenshots: screenshots,
      videos: videos,
      totalRating: totalRating,
      platformIds: platformIds,
      genreIds: genreIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coverUrl': coverUrl,
        'releaseDate': releaseDate?.millisecondsSinceEpoch,
        'summary': summary,
        'screenshots': screenshots,
        'videos': videos,
        'totalRating': totalRating,
        'platformIds': platformIds,
        'genreIds': genreIds,
      };
}
