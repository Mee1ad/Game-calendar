import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_calendar/features/favorites/data/repositories/favorites_repository.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/data/repositories/games_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({
    required FavoritesRepository favoritesRepo,
    required GamesRepository gamesRepo,
  })  : _favoritesRepo = favoritesRepo,
        _gamesRepo = gamesRepo,
        super(const FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoad);
    on<FavoritesToggled>(_onToggle);
  }

  final FavoritesRepository _favoritesRepo;
  final GamesRepository _gamesRepo;
  StreamSubscription? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
      FavoritesLoadRequested e, Emitter<FavoritesState> emit) async {
    emit(const FavoritesLoading());
    try {
      _sub?.cancel();
      _sub = _favoritesRepo.watchFavoriteIds().listen((_) {
        add(const FavoritesLoadRequested());
      });

      final ids = _favoritesRepo.getFavoriteIdsOrdered();
      final games = ids
          .map((id) => _gamesRepo.getGame(id))
          .whereType<Game>()
          .toList();

      final grouped = <String, List<Game>>{};
      for (final g in games) {
        grouped.putIfAbsent(g.releaseMonthKey, () => []).add(g);
      }
      for (final list in grouped.values) {
        list.sort((a, b) => (a.releaseDate ?? DateTime(0))
            .compareTo(b.releaseDate ?? DateTime(0)));
      }

      emit(FavoritesStateX.loaded(
        games: games,
        groupedByMonth: grouped,
        favoriteIds: _favoritesRepo.getFavoriteIds(),
      ));
    } catch (err, st) {
      emit(FavoritesStateX.error('$err\n\n$st'));
    }
  }

  Future<void> _onToggle(FavoritesToggled e, Emitter<FavoritesState> emit) async {
    await _favoritesRepo.toggleFavorite(e.gameId);
    add(const FavoritesLoadRequested());
  }
}
