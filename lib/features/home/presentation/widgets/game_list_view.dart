import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';
import 'package:game_calendar/features/games/presentation/widgets/game_card.dart';

class GameListView extends StatelessWidget {
  const GameListView({
    super.key,
    required this.games,
    required this.favoriteIds,
  });

  final List<Game> games;
  final Set<int> favoriteIds;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => RepaintBoundary(
                child: GameCard(
                  game: games[index],
                  isFavorite: favoriteIds.contains(games[index].id),
                  onFavoriteTap: () =>
                      bloc.add(GameFavoriteToggled(games[index].id)),
                ),
              ),
              childCount: games.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
