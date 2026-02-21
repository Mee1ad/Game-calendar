import 'package:game_calendar/features/favorites/data/adapters/favorite_hive_adapter.dart';
import 'package:game_calendar/features/favorites/data/repositories/favorites_repository.dart';
import 'package:game_calendar/features/games/data/adapters/game_hive_adapter.dart';
import 'package:game_calendar/features/games/data/repositories/games_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(GameHiveModelAdapter());
  Hive.registerAdapter(FavoriteHiveModelAdapter());
}

Future<GamesRepository> createGamesRepository() async {
  final box = await Hive.openBox<GameHiveModel>('games');
  return GamesRepository(box: box);
}

Future<FavoritesRepository> createFavoritesRepository() async {
  final box = await Hive.openBox<FavoriteHiveModel>('favorites');
  return FavoritesRepository(box: box);
}
