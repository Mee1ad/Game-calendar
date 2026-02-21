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

  Future<Result<List<GameEntity>>> searchGames(
    String query, {
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
    int limit = 50,
  }) async {
    return _fetchStructured(
      search: query,
      platformIds: platformIds,
      genreIds: genreIds,
      limit: limit,
    );
  }

  Future<Result<List<GameEntity>>> fetchFiltered({
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
    int limit = 50,
  }) async {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final conditions = <String>['first_release_date > $now', 'cover != null'];
    if (platformIds.isNotEmpty) {
      conditions.add('platforms = (${platformIds.join(",")})');
    }
    if (genreIds.isNotEmpty) {
      conditions.add('genres = (${genreIds.join(",")})');
    }
    final query = '''
      fields $_fields;
      where ${conditions.join(' & ')};
      sort first_release_date asc;
      limit $limit;
    ''';
    return _fetch(query);
  }

  Future<Result<List<GameEntity>>> _fetchStructured({
    String search = '',
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
    int limit = 50,
  }) async {
    try {
      final body = <String, dynamic>{
        'endpoint': 'games',
        'search': search,
        'filters': {
          if (platformIds.isNotEmpty) 'platformIds': platformIds.toList(),
          if (genreIds.isNotEmpty) 'genreIds': genreIds.toList(),
          'limit': limit,
        },
      };

      final response = await Supabase.instance.client.functions.invoke(
        'igdb-proxy',
        body: body,
      );
      return _parseResponse(response);
    } catch (e, st) {
      return Failure(e.toString(), st);
    }
  }

  Future<Result<List<GameEntity>>> _fetch(String query) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'igdb-proxy',
        body: {'endpoint': 'games', 'query': query},
      );
      return _parseResponse(response);
    } catch (e, st) {
      return Failure(e.toString(), st);
    }
  }

  Result<List<GameEntity>> _parseResponse(dynamic response) {
    if (response.status != 200) {
      final err =
          response.data is Map ? response.data['error'] : null;
      return Failure(err?.toString() ?? 'Request failed: ${response.status}');
    }

    final data = response.data;
    if (data is! List) return Failure('Unexpected response format');

    final games = data
        .whereType<Map<String, dynamic>>()
        .map((e) => GameEntity.fromJson(e))
        .toList();
    return Success(games);
  }
}
