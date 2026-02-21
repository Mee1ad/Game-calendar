import 'package:game_calendar/core/result/result.dart';
import 'package:game_calendar/features/games/data/entities/game_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IgdbRemoteDatasource {
  static const _fields =
      'name,cover.url,first_release_date,summary,screenshots.url,videos.video_id,'
      'total_rating,platforms,genres';

  Future<Result<List<GameEntity>>> fetchComingSoon({int limit = 50}) async {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final query = '''
      fields $_fields;
      where first_release_date > $now & cover != null;
      sort first_release_date asc;
      limit $limit;
    ''';
    return _fetch(query);
  }

  Future<Result<List<GameEntity>>> fetchPopular({int limit = 50}) async {
    final query = '''
      fields $_fields;
      where first_release_date != null & cover != null;
      sort first_release_date desc;
      limit $limit;
    ''';
    return _fetch(query);
  }

  Future<Result<List<GameEntity>>> _fetch(String query) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'igdb-proxy',
        body: {'endpoint': 'games', 'query': query},
      );

      if (response.status != 200) {
        final err =
            response.data is Map ? (response.data as Map)['error'] : null;
        return Failure(err?.toString() ?? 'Request failed: ${response.status}');
      }

      final data = response.data;
      if (data is! List) return Failure('Unexpected response format');

      final games = (data as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => GameEntity.fromJson(e))
          .toList();
      return Success(games);
    } catch (e, st) {
      return Failure(e.toString(), st);
    }
  }
}
