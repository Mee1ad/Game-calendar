import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';
import 'package:game_calendar/features/games/presentation/widgets/filter_sheet.dart';
import 'package:game_calendar/features/favorites/presentation/pages/favorites_page.dart';
import 'package:game_calendar/features/home/presentation/widgets/error_view.dart';
import 'package:game_calendar/features/home/presentation/widgets/game_list_view.dart';
import 'package:game_calendar/features/home/presentation/widgets/shimmer_grid.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Game Calendar'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            BlocBuilder<GameBloc, GameState>(
              buildWhen: (a, b) => a is GameSuccess && b is GameSuccess,
              builder: (context, state) {
                if (state is! GameSuccess) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => FilterSheet(
                      filters: state.filters,
                      onFiltersChanged: (f) =>
                          context.read<GameBloc>().add(GameFiltersChanged(f)),
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sports_esports), text: 'Coming Soon'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GamesTab(),
            const FavoritesPage(),
          ],
        ),
      ),
    );
  }
}

class _GamesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return switch (state) {
          GameInitial() || GameLoading() => const ShimmerGrid(),
          GameFailure(:final message) => GamesErrorView(message: message),
          GameSuccess(
            :final filteredGames,
            :final favoriteIds,
            :final isRefreshing,
            :final isSearching,
            :final searchQuery,
          ) =>
            RefreshIndicator(
              onRefresh: () async {
                context.read<GameBloc>().add(const GameRefreshRequested());
              },
              child: Stack(
                children: [
                  GameListView(
                    games: filteredGames,
                    favoriteIds: favoriteIds,
                    searchQuery: searchQuery,
                    isSearching: isSearching,
                  ),
                  if (isRefreshing)
                    const Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
