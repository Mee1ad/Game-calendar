part of 'game_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class GameLoadRequested extends GameEvent {
  const GameLoadRequested();
}

final class GameRefreshRequested extends GameEvent {
  const GameRefreshRequested();
}

final class GameFiltersChanged extends GameEvent {
  const GameFiltersChanged(this.filters);
  final GameFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class GameListTypeChanged extends GameEvent {
  const GameListTypeChanged(this.listType);
  final GameListType listType;

  @override
  List<Object?> get props => [listType];
}

final class GameFavoriteToggled extends GameEvent {
  const GameFavoriteToggled(this.gameId);
  final int gameId;

  @override
  List<Object?> get props => [gameId];
}

final class GameFavoritesUpdated extends GameEvent {
  const GameFavoritesUpdated(this.ids);
  final Set<int> ids;

  @override
  List<Object?> get props => [ids];
}

final class GameSearchChanged extends GameEvent {
  const GameSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
