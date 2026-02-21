import 'dart:async';
import 'package:game_calendar/core/result/result.dart';
import 'package:game_calendar/features/games/data/adapters/game_hive_adapter.dart';
import 'package:game_calendar/features/games/data/datasources/igdb_remote_datasource.dart';
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

  Future<Result<List<Game>>> loadAndSync() async {
    final cached = await _allFromHive();
    final result = await _remote.fetchComingSoon();

    return switch (result) {
      Failure() => cached.isNotEmpty ? Success(cached) : result,
      Success(:final data) => () async {
          await box.clear();
          for (final e in data) {
            await box.put(e.id, GameHiveModel.fromEntity(e));
          }
          return Success<List<Game>>(
              data.map((e) => e.toDomain()).toList());
        }(),
    };
  }

  Future<Result<List<Game>>> refresh() async {
    final result = await _remote.fetchComingSoon();
    return switch (result) {
      Failure() => result,
      Success(:final data) => () async {
          await box.clear();
          for (final e in data) {
            await box.put(e.id, GameHiveModel.fromEntity(e));
          }
          return Success<List<Game>>(
              data.map((e) => e.toDomain()).toList());
        }(),
    };
  }

  Game? getGame(int id) {
    final m = box.get(id);
    return m?.toEntity().toDomain();
  }
}
