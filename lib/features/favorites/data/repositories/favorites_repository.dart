import 'dart:async';
import 'package:game_calendar/features/favorites/data/adapters/favorite_hive_adapter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  FavoritesRepository({required this.box});

  final Box<FavoriteHiveModel> box;

  Stream<Set<int>> watchFavoriteIds() {
    return box.watch().map((_) => getFavoriteIds());
  }

  Set<int> getFavoriteIds() =>
      box.values.map((m) => m.gameId).toSet();

  bool isFavorite(int gameId) => box.containsKey('f_$gameId');

  Future<void> toggleFavorite(int gameId) async {
    final key = 'f_$gameId';
    if (box.containsKey(key)) {
      await box.delete(key);
      _syncRemove(gameId);
    } else {
      await box.put(
        key,
        FavoriteHiveModel(
          gameId: gameId,
          addedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _syncAdd(gameId);
    }
  }

  void _syncAdd(int gameId) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    Supabase.instance.client.from('user_favorites').upsert({
      'user_id': uid,
      'game_id': gameId,
    }).then((_) {}).catchError((_) {});
  }

  void _syncRemove(int gameId) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    Supabase.instance.client
        .from('user_favorites')
        .delete()
        .eq('user_id', uid)
        .eq('game_id', gameId)
        .then((_) {})
        .catchError((_) {});
  }

  List<int> getFavoriteIdsOrdered() {
    final list = box.values.toList()
      ..sort((a, b) => a.addedAtMs.compareTo(b.addedAtMs));
    return list.map((m) => m.gameId).toList();
  }
}
