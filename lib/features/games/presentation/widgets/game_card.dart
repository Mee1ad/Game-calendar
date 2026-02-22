import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:game_calendar/core/widgets/game_card_morph.dart';
import 'package:game_calendar/features/games/domain/models/game.dart';
import 'package:game_calendar/features/games/presentation/pages/game_detail_page.dart';

const _neonPurple = Color(0xFFBB86FC);

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
    return RepaintBoundary(
      child: GameCardMorph<void>(
        closedBuilder: (ctx, open) => GestureDetector(
          onTap: open,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: const Color(0xFF1A1A2E),
                child: Stack(
                  fit: StackFit.expand,
                  children: [_cover(), _glassInfo(), _favButton()],
                ),
              ),
            ),
          ),
        ),
        openBuilder: (ctx, _) =>
            GameDetailPage(game: game, onFavoriteTap: onFavoriteTap),
      ),
    );
  }

  Widget _cover() {
    if (game.coverUrl == null) return _placeholder();
    return CachedNetworkImage(
      imageUrl: game.coverUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade800,
        child: Container(color: Colors.grey.shade900),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _glassInfo() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
            child: Text(
              game.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _favButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onFavoriteTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black38,
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorite ? _neonPurple : Colors.white70,
            shadows: isFavorite
                ? [const Shadow(color: _neonPurple, blurRadius: 12)]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child:
              Icon(Icons.sports_esports, size: 48, color: Colors.white24),
        ),
      );
}
