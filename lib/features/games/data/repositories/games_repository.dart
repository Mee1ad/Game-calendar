import 'dart:async';
import 'package:game_calendar/core/result/result.dart';
import 'package:game_calendar/features/games/data/adapters/game_hive_adapter.dart';
import 'package:game_calendar/features/games/data/datasources/igdb_remote_datasource.dart';
import 'package:game_calendar/features/games/data/entities/game_entity.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GamesRepository {
  GamesRepository({
    IgdbRemoteDatasource? remote,
    required this.box,
  }) : _remote = remote ?? IgdbRemoteDatasource();

  final IgdbRemoteDatasource _remote;
  final Box<GameHiveModel> box;

  Stream<List<Game>> watchGames() {
    return box.watch().asyncMap((_) => _allFromHive());
  }

  Future<List<Game>> _allFromHive() async {
    return box.values.map((m) => m.toEntity().toDomain()).toList();
  }

  Future<List<Game>> getCachedGames() => _allFromHive();

  Future<Result<List<Game>>> loadAndSync({
    String listType = 'popular',
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
  }) async {
    final cached = await _allFromHive();
    final result = await _remote.fetchByListType(
      listType,
      platformIds: platformIds,
      genreIds: genreIds,
    );

    switch (result) {
      case Failure(:final message, :final stackTrace):
        return cached.isNotEmpty
            ? Success<List<Game>>(cached)
            : Failure<List<Game>>(message, stackTrace);
      case Success(:final data):
        await _cacheEntities(data);
        return Success<List<Game>>(data.map((e) => e.toDomain()).toList());
    }
  }

  Future<Result<List<Game>>> refresh({
    String listType = 'popular',
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
  }) async {
    final result = await _remote.fetchByListType(
      listType,
      platformIds: platformIds,
      genreIds: genreIds,
    );
    switch (result) {
      case Failure(:final message, :final stackTrace):
        return Failure<List<Game>>(message, stackTrace);
      case Success(:final data):
        await _cacheEntities(data);
        return Success<List<Game>>(data.map((e) => e.toDomain()).toList());
    }
  }

  Future<Result<List<Game>>> searchGames(
    String query, {
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
  }) async {
    final result = await _remote.searchGames(
      query,
      platformIds: platformIds,
      genreIds: genreIds,
    );
    return _mapResult(result);
  }

  Future<Result<List<Game>>> fetchFiltered({
    String listType = 'popular',
    Set<int> platformIds = const {},
    Set<int> genreIds = const {},
  }) async {
    final result = await _remote.fetchByListType(
      listType,
      platformIds: platformIds,
      genreIds: genreIds,
    );
    return _mapResult(result);
  }

  Game? getGame(int id) {
    final m = box.get(id);
    return m?.toEntity().toDomain();
  }

  Result<List<Game>> _mapResult(Result<List<GameEntity>> result) {
    switch (result) {
      case Failure(:final message, :final stackTrace):
        return Failure(message, stackTrace);
      case Success(:final data):
        return Success(data.map((e) => e.toDomain()).toList());
    }
  }

  Future<void> _cacheEntities(List<GameEntity> entities) async {
    await box.clear();
    for (final e in entities) {
      await box.put(e.id, GameHiveModel.fromEntity(e));
    }
  }
}
