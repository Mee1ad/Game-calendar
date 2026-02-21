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
