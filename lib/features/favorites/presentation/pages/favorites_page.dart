import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/widgets/game_card.dart';
import 'package:game_calendar/features/favorites/presentation/bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => context.read<FavoritesBloc>()
          ..add(const FavoritesLoadRequested()),
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            try {
              return switch (state) {
                FavoritesInitial() || FavoritesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                FavoritesError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 16),
                            Text(message, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                FavoritesLoaded(
                  :final groupedByMonth,
                  :final favoriteIds
                ) =>
                  _FavoritesList(
                    groupedByMonth: groupedByMonth,
                    favoriteIds: favoriteIds,
                  ),
              };
            } catch (e, st) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Error: $e', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text('$st', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({
    required this.groupedByMonth,
    required this.favoriteIds,
  });

  final Map<String, List<Game>> groupedByMonth;
  final Set<int> favoriteIds;

  @override
  Widget build(BuildContext context) {
    if (groupedByMonth.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart on any game to add it here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final bloc = context.read<FavoritesBloc>();
    final sortedMonths = groupedByMonth.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        for (final monthKey in sortedMonths) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                _formatMonthKey(monthKey),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final game = groupedByMonth[monthKey]![index];
                  return RepaintBoundary(
                    child: GameCard(
                      game: game,
                      isFavorite: true,
                      onFavoriteTap: () =>
                          bloc.add(FavoritesToggled(game.id)),
                    ),
                  );
                },
                childCount: groupedByMonth[monthKey]!.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  String _formatMonthKey(String key) {
    if (key == 'Unknown') return key;
    final parts = key.split('-');
    if (parts.length != 2) return key;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = int.tryParse(parts[1]) ?? 1;
    return '${months[m - 1]} ${parts[0]}';
  }
}
