import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/core/widgets/shimmer_loading.dart';
import 'package:game_calendar/features/games/domain/filter_models.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';
import 'package:game_calendar/features/games/presentation/widgets/game_card.dart';

class GameListView extends StatefulWidget {
  const GameListView({
    super.key,
    required this.games,
    required this.favoriteIds,
    required this.searchQuery,
    required this.listType,
    this.isSearching = false,
    this.isRefreshing = false,
  });

  final List<Game> games;
  final Set<int> favoriteIds;
  final String searchQuery;
  final GameListType listType;
  final bool isSearching;
  final bool isRefreshing;

  @override
  State<GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends State<GameListView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant GameListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _listTypeLabel(GameListType t) => switch (t) {
        GameListType.popular => 'Popular',
        GameListType.upcoming => 'Upcoming',
        GameListType.top => 'Top Rated',
        GameListType.recent => 'Recent',
      };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    final theme = Theme.of(context);
    final isUpcoming = widget.listType == GameListType.upcoming;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => bloc.add(GameSearchChanged(q)),
              decoration: InputDecoration(
                hintText: 'Search games...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          bloc.add(const GameSearchChanged(''));
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GameListType.values.map((t) {
                  final selected = widget.listType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_listTypeLabel(t)),
                      selected: selected,
                      onSelected: (_) =>
                          bloc.add(GameListTypeChanged(t)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.searchQuery.isNotEmpty
                  ? 'Search Results'
                  : _listTypeLabel(widget.listType),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (widget.isSearching || (widget.isRefreshing && widget.games.isEmpty))
          _buildShimmerGrid()
        else if (widget.games.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                widget.searchQuery.isNotEmpty
                    ? 'No results for "${widget.searchQuery}"'
                    : 'No games found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else if (isUpcoming)
          _buildUpcomingGrouped(bloc, theme)
        else
          _buildGrid(bloc),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildUpcomingGrouped(GameBloc bloc, ThemeData theme) {
    final grouped = <String, List<Game>>{};
    for (final g in widget.games) {
      final key = g.releaseMonthKey;
      grouped.putIfAbsent(key, () => []).add(g);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final monthKey = sortedKeys[index];
          final games = grouped[monthKey]!;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 24, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMonthKey(monthKey),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: games.length,
                    itemBuilder: (_, i) {
                    final game = games[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (game.releaseDate != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _formatDate(game.releaseDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Expanded(
                          child: GameCard(
                            game: game,
                            isFavorite: widget.favoriteIds.contains(game.id),
                            onFavoriteTap: () =>
                                bloc.add(GameFavoriteToggled(game.id)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
        childCount: sortedKeys.length,
      ),
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

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _buildGrid(GameBloc bloc) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => GameCard(
            game: widget.games[index],
            isFavorite: widget.favoriteIds.contains(widget.games[index].id),
            onFavoriteTap: () =>
                bloc.add(GameFavoriteToggled(widget.games[index].id)),
          ),
          childCount: widget.games.length,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const RepaintBoundary(
            child: ShimmerGameCard(),
          ),
          childCount: 6,
        ),
      ),
    );
  }
}
