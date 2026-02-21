part of 'game_bloc.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

final class GameInitial extends GameState {
  const GameInitial();
}

final class GameLoading extends GameState {
  const GameLoading();
}

final class GameFailure extends GameState {
  const GameFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class GameSuccess extends GameState {
  const GameSuccess({
    required this.games,
    required this.filteredGames,
    required this.filters,
    required this.favoriteIds,
    this.isRefreshing = false,
    this.isSearching = false,
    this.searchQuery = '',
  });

  final List<Game> games;
  final List<Game> filteredGames;
  final GameFilters filters;
  final Set<int> favoriteIds;
  final bool isRefreshing;
  final bool isSearching;
  final String searchQuery;

  GameSuccess copyWith({
    List<Game>? games,
    List<Game>? filteredGames,
    GameFilters? filters,
    Set<int>? favoriteIds,
    bool? isRefreshing,
    bool? isSearching,
    String? searchQuery,
  }) =>
      GameSuccess(
        games: games ?? this.games,
        filteredGames: filteredGames ?? this.filteredGames,
        filters: filters ?? this.filters,
        favoriteIds: favoriteIds ?? this.favoriteIds,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isSearching: isSearching ?? this.isSearching,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [
        games,
        filteredGames,
        filters,
        favoriteIds,
        isRefreshing,
        isSearching,
        searchQuery,
      ];
}
