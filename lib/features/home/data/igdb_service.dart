import 'package:game_calendar/core/result/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IgdbGame {
  const IgdbGame({
    required this.id,
    required this.name,
    this.coverUrl,
    this.releaseDate,
  });

  final int id;
  final String name;
  final String? coverUrl;
  final DateTime? releaseDate;

  factory IgdbGame.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    final cover = json['cover'];
    if (cover is Map && cover['url'] != null) {
      final url = cover['url'].toString();
      coverUrl = url.startsWith('http') ? url : 'https://images.igdb.com/igdb/image/upload/$url';
    }

    DateTime? releaseDate;
    final ts = json['first_release_date'];
    if (ts != null) {
      releaseDate = DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000);
    }

    return IgdbGame(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      coverUrl: coverUrl,
      releaseDate: releaseDate,
    );
  }
}

class IgdbService {
  Future<Result<List<IgdbGame>>> fetchComingSoon({int limit = 20}) async {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final query = '''
      fields name,cover.url,first_release_date;
      where first_release_date > $now & cover != null;
      sort first_release_date asc;
      limit $limit;
    ''';
    return _fetchGames(query);
  }

  Future<Result<List<IgdbGame>>> fetchPopular({int limit = 20}) async {
    final query = '''
      fields name,cover.url,first_release_date;
      where first_release_date != null & cover != null;
      sort first_release_date desc;
      limit $limit;
    ''';
    return _fetchGames(query);
  }

  Future<Result<List<IgdbGame>>> _fetchGames(String query) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'igdb-proxy',
        body: {'endpoint': 'games', 'query': query},
      );

      if (response.status != 200) {
        final err = response.data is Map ? (response.data as Map)['error'] : null;
        return Failure(err?.toString() ?? 'Request failed: ${response.status}');
      }

      final data = response.data;
      if (data is! List) {
        return Failure('Unexpected response format');
      }

      final games = data
          .whereType<Map<String, dynamic>>()
          .map((e) => IgdbGame.fromJson(e))
          .toList();
      return Success(games);
    } catch (e, st) {
      return Failure(e.toString(), st);
    }
  }
}
