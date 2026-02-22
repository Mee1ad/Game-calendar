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
    on<GameListTypeChanged>(_onListTypeChanged);
    on<GameRefreshRequested>(_onRefresh);
    on<GameFiltersChanged>(_onFiltersChanged);
    on<GameFavoriteToggled>(_onFavoriteToggled);
    on<GameFavoritesUpdated>(_onFavoritesUpdated);
    on<GameSearchChanged>(_onSearchChanged);
  }

  final GamesRepository _gamesRepo;
  final FavoritesRepository _favoritesRepo;
  GameFilters _currentFilters = const GameFilters();
  GameListType _listType = GameListType.popular;
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
        listType: _listType,
      ));
    }

    final result = await _gamesRepo.loadAndSync(_listType);
    switch (result) {
      case Failure(:final message):
        if (cached.isEmpty) emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: data,
          filters: _currentFilters,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
          listType: _listType,
        ));
    }
  }

  Future<void> _onListTypeChanged(
      GameListTypeChanged e, Emitter<GameState> emit) async {
    _listType = e.listType;
    final current = state;
    if (current is GameSuccess) {
      emit(current.copyWith(
        listType: e.listType,
        isRefreshing: true,
        filteredGames: [],
      ));
    } else {
      emit(const GameLoading());
    }

    final result = await _gamesRepo.loadAndSync(e.listType);
    switch (result) {
      case Failure(:final message):
        emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: data,
          filters: _currentFilters,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
          listType: e.listType,
          isRefreshing: false,
          searchQuery: _searchQuery,
        ));
    }
  }

  Future<void> _onRefresh(
      GameRefreshRequested e, Emitter<GameState> emit) async {
    final current = state;
    if (current is! GameSuccess) return;
    emit(current.copyWith(isRefreshing: true));

    final result = await _gamesRepo.refresh(_listType);
    switch (result) {
      case Failure(:final message):
        emit(GameFailure(message));
      case Success(:final data):
        emit(GameSuccess(
          games: data,
          filteredGames: data,
          filters: _currentFilters,
          favoriteIds: _favoritesRepo.getFavoriteIds(),
          listType: _listType,
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
      emit(current.copyWith(
        filteredGames: current.games,
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
        _listType,
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
          filteredGames: data,
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
          _listType,
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
              filteredGames: data,
              isSearching: false,
              searchQuery: '',
            ));
        }
      } else {
        emit(current.copyWith(
          filteredGames: current.games,
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
          filteredGames: data,
          isSearching: false,
          searchQuery: e.query,
        ));
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
