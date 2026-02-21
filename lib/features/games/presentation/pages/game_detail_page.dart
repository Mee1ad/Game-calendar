import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({
    super.key,
    required this.game,
    required this.onFavoriteTap,
  });

  final Game game;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: game.coverUrl != null
                  ? Image.network(
                      game.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme),
                    )
                  : _placeholder(theme),
            ),
            actions: [
              BlocBuilder<GameBloc, GameState>(
                buildWhen: (a, b) =>
                    a is GameSuccess &&
                    b is GameSuccess &&
                    a.favoriteIds != b.favoriteIds,
                builder: (context, state) {
                  final isFav = state is GameSuccess
                      ? state.favoriteIds.contains(game.id)
                      : false;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: onFavoriteTap,
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (game.releaseDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(game.releaseDate!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (game.totalRating != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${(game.totalRating! / 10).toStringAsFixed(1)}/10',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                  if (game.summary != null && game.summary!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      game.summary!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (game.screenshots.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Screenshots',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: game.screenshots.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            game.screenshots[i],
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 200,
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.sports_esports_outlined,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
