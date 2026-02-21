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
    on<GameSearchChanged>(_onSearchChanged);
  }

  final GamesRepository _gamesRepo;
  final FavoritesRepository _favoritesRepo;
  GameFilters _currentFilters = const GameFilters();
  String _searchQuery = '';
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
      emit(GameSuccess(
        games: cached,
        filteredGames: cached,
        filters: _currentFilters,
        favoriteIds: _favoritesRepo.getFavoriteIds(),
      ));
    }

    final result = await _gamesRepo.loadAndSync();
    switch (result) {
      case Failure(:final message):
        if (cached.isEmpty) emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: data,
          filters: _currentFilters,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
        ));
    }
  }

  Future<void> _onRefresh(
      GameRefreshRequested e, Emitter<GameState> emit) async {
    final current = state;
    if (current is! GameSuccess) return;
    emit(current.copyWith(isRefreshing: true));

    final result = await _gamesRepo.refresh();
    switch (result) {
      case Failure(:final message):
        emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: _applyReleaseStatus(data, _currentFilters),
          filters: _currentFilters,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
          isRefreshing: false,
          searchQuery: _searchQuery,
        ));
    }
  }

  Future<void> _onFiltersChanged(
      GameFiltersChanged e, Emitter<GameState> emit) async {
    _currentFilters = e.filters;
    final current = state;
    if (current is! GameSuccess) return;

    final hasRemoteFilters =
        e.filters.platformIds.isNotEmpty || e.filters.genreIds.isNotEmpty;

    if (!hasRemoteFilters && _searchQuery.isEmpty) {
      final filtered = _applyReleaseStatus(current.games, e.filters);
      emit(current.copyWith(
        filteredGames: filtered,
        filters: e.filters,
      ));
      return;
    }

    emit(current.copyWith(isSearching: true, filters: e.filters));

    final Result<List<Game>> result;
    if (_searchQuery.isNotEmpty) {
      result = await _gamesRepo.searchGames(
        _searchQuery,
        platformIds: e.filters.platformIds,
        genreIds: e.filters.genreIds,
      );
    } else {
      result = await _gamesRepo.fetchFiltered(
        platformIds: e.filters.platformIds,
        genreIds: e.filters.genreIds,
      );
    }

    final s = state;
    if (s is! GameSuccess) return;
    switch (result) {
      case Failure():
        emit(s.copyWith(isSearching: false));
      case Success(:final data):
        emit(s.copyWith(
          filteredGames: _applyReleaseStatus(data, _currentFilters),
          isSearching: false,
        ));
    }
  }

  Future<void> _onSearchChanged(
      GameSearchChanged e, Emitter<GameState> emit) async {
    _searchQuery = e.query;
    final current = state;
    if (current is! GameSuccess) return;

    if (e.query.trim().isEmpty) {
      final hasRemoteFilters = _currentFilters.platformIds.isNotEmpty ||
          _currentFilters.genreIds.isNotEmpty;

      if (hasRemoteFilters) {
        emit(current.copyWith(
            isSearching: true, searchQuery: '', filteredGames: []));
        final result = await _gamesRepo.fetchFiltered(
          platformIds: _currentFilters.platformIds,
          genreIds: _currentFilters.genreIds,
        );
        final s = state;
        if (s is! GameSuccess) return;
        switch (result) {
          case Failure():
            emit(s.copyWith(
              filteredGames: s.games,
              isSearching: false,
              searchQuery: '',
            ));
          case Success(:final data):
            emit(s.copyWith(
              filteredGames: _applyReleaseStatus(data, _currentFilters),
              isSearching: false,
              searchQuery: '',
            ));
        }
      } else {
        emit(current.copyWith(
          filteredGames:
              _applyReleaseStatus(current.games, _currentFilters),
          searchQuery: '',
          isSearching: false,
        ));
      }
      return;
    }

    emit(current.copyWith(isSearching: true, searchQuery: e.query));

    await Future.delayed(const Duration(milliseconds: 400));
    if (_searchQuery != e.query) return;

    final result = await _gamesRepo.searchGames(
      e.query,
      platformIds: _currentFilters.platformIds,
      genreIds: _currentFilters.genreIds,
    );
    if (_searchQuery != e.query) return;

    final s = state;
    if (s is! GameSuccess) return;
    switch (result) {
      case Failure():
        emit(s.copyWith(isSearching: false));
      case Success(:final data):
        emit(s.copyWith(
          filteredGames: _applyReleaseStatus(data, _currentFilters),
          isSearching: false,
          searchQuery: e.query,
        ));
    }
  }

  List<Game> _applyReleaseStatus(List<Game> games, GameFilters f) {
    switch (f.releaseStatus) {
      case ReleaseStatus.released:
        final now = DateTime.now();
        return games
            .where(
                (g) => g.releaseDate != null && g.releaseDate!.isBefore(now))
            .toList();
      case ReleaseStatus.upcoming:
        final now = DateTime.now();
        return games
            .where(
                (g) => g.releaseDate != null && !g.releaseDate!.isBefore(now))
            .toList();
      case ReleaseStatus.all:
        return games;
    }
  }

  Future<void> _onFavoriteToggled(
      GameFavoriteToggled e, Emitter<GameState> emit) async {
    await _favoritesRepo.toggleFavorite(e.gameId);
    final current = state;
    if (current is GameSuccess) {
      emit(current.copyWith(favoriteIds: _favoritesRepo.getFavoriteIds()));
    }
  }

  void _onFavoritesUpdated(GameFavoritesUpdated e, Emitter<GameState> emit) {
    final current = state;
    if (current is GameSuccess) {
      emit(current.copyWith(favoriteIds: e.ids));
    }
  }
}
