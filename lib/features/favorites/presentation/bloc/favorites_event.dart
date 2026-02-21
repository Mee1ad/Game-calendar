part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

final class FavoritesToggled extends FavoritesEvent {
  const FavoritesToggled(this.gameId);
  final int gameId;

  @override
  List<Object?> get props => [gameId];
}
