import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_calendar/core/widgets/game_card_morph.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/bloc/game_bloc.dart';
import 'package:game_calendar/features/games/presentation/pages/game_detail_page.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final Game game;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: GameCardMorph<void>(
        closedBuilder: (context, openContainer) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: theme.colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: openContainer,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: game.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: game.coverUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _placeholder(theme),
                              errorWidget: (_, __, ___) => _placeholder(theme),
                            )
                          : _placeholder(theme),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (game.releaseDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(game.releaseDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
                    ),
                    onPressed: onFavoriteTap,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        openBuilder: (context, _) => GameDetailPage(
          game: game,
          onFavoriteTap: onFavoriteTap,
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.sports_esports_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
