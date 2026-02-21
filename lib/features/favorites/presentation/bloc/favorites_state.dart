part of 'favorites_bloc.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({
    required this.games,
    required this.groupedByMonth,
    required this.favoriteIds,
  });

  final List<Game> games;
  final Map<String, List<Game>> groupedByMonth;
  final Set<int> favoriteIds;

  @override
  List<Object?> get props => [games, groupedByMonth, favoriteIds];
}

extension FavoritesStateX on FavoritesState {
  static const initial = FavoritesInitial();
  static FavoritesLoaded loaded({
    required List<Game> games,
    required Map<String, List<Game>> groupedByMonth,
    required Set<int> favoriteIds,
  }) =>
      FavoritesLoaded(
        games: games,
        groupedByMonth: groupedByMonth,
        favoriteIds: favoriteIds,
      );
}
