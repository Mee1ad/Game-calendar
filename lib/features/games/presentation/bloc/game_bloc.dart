import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_calendar/core/result/result.dart';
import 'package:game_calendar/features/games/domain/filter_models.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/data/repositories/games_repository.dart';
import 'package:game_calendar/features/favorites/data/repositories/favorites_repository.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required GamesRepository gamesRepo,
    required FavoritesRepository favoritesRepo,
  })  : _gamesRepo = gamesRepo,
        _favoritesRepo = favoritesRepo,
        super(const GameInitial()) {
    on<GameLoadRequested>(_onLoad);
    on<GameRefreshRequested>(_onRefresh);
    on<GameFiltersChanged>(_onFiltersChanged);
    on<GameFavoriteToggled>(_onFavoriteToggled);
    on<GameFavoritesUpdated>(_onFavoritesUpdated);
  }

  final GamesRepository _gamesRepo;
  final FavoritesRepository _favoritesRepo;
  GameFilters? _currentFilters;
  StreamSubscription? _favoritesSub;

  @override
  Future<void> close() {
    _favoritesSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(GameLoadRequested e, Emitter<GameState> emit) async {
    emit(const GameLoading());
    _favoritesSub?.cancel();
    _favoritesSub = _favoritesRepo.watchFavoriteIds().listen((ids) {
      add(GameFavoritesUpdated(ids));
    });

    final cached = await _gamesRepo.getCachedGames();
    if (cached.isNotEmpty) {
      _currentFilters = const GameFilters();
      emit(GameSuccess(
        games: cached,
        filteredGames: _applyFilters(cached, _currentFilters!),
        filters: _currentFilters!,
        favoriteIds: _favoritesRepo.getFavoriteIds(),
      ));
    }

    final result = await _gamesRepo.loadAndSync();
    _currentFilters = const GameFilters();

    switch (result) {
      case Failure(:final message):
        if (cached.isEmpty) emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: _applyFilters(data, _currentFilters!),
          filters: _currentFilters!,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
        ));
    }
  }

  Future<void> _onRefresh(GameRefreshRequested e, Emitter<GameState> emit) async {
    final current = state;
    if (current is! GameSuccess) return;
        emit(current.copyWith(isRefreshing: true));

    final result = await _gamesRepo.refresh();
    _currentFilters = current.filters;

    switch (result) {
      case Failure(:final message):
        emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: _applyFilters(data, _currentFilters!),
          filters: _currentFilters!,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
          isRefreshing: false,
        ));
    }
  }

  void _onFiltersChanged(GameFiltersChanged e, Emitter<GameState> emit) {
    _currentFilters = e.filters;
    final current = state;
    if (current is! GameSuccess) return;

    final filtered = _applyFilters(current.games, e.filters);
    emit(current.copyWith(
      filteredGames: filtered,
      filters: e.filters,
      favoriteIds: _favoritesRepo.getFavoriteIds(),
    ));
  }

  List<Game> _applyFilters(List<Game> games, GameFilters f) {
    var result = games;

    if (f.platformIds.isNotEmpty) {
      result = result
          .where((g) => g.platformIds.any((p) => f.platformIds.contains(p)))
          .toList();
    }
    if (f.genreIds.isNotEmpty) {
      result = result
          .where((g) => g.genreIds.any((gr) => f.genreIds.contains(gr)))
          .toList();
    }
    switch (f.releaseStatus) {
      case ReleaseStatus.released:
        final now = DateTime.now();
        result = result
            .where((g) => g.releaseDate != null && g.releaseDate!.isBefore(now))
            .toList();
        break;
      case ReleaseStatus.upcoming:
        final now = DateTime.now();
        result = result
            .where((g) =>
                g.releaseDate != null && !g.releaseDate!.isBefore(now))
            .toList();
        break;
      case ReleaseStatus.all:
        break;
    }
    return result;
  }

  Future<void> _onFavoriteToggled(
      GameFavoriteToggled e, Emitter<GameState> emit) async {
    await _favoritesRepo.toggleFavorite(e.gameId);
    final current = state;
    if (current is GameSuccess) {
      emit(current.copyWith(
        favoriteIds: _favoritesRepo.getFavoriteIds(),
      ));
    }
  }

  void _onFavoritesUpdated(GameFavoritesUpdated e, Emitter<GameState> emit) {
    final current = state;
    if (current is GameSuccess) {
      emit(current.copyWith(favoriteIds: e.ids));
    }
  }
}
