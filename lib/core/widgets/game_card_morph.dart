import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Wraps content in RepaintBoundary + OpenContainer for 120Hz Morph.
/// Strategy: Isolate repaints, use transform-based animation, avoid layout thrash.
class GameCardMorph<T> extends StatelessWidget {
  const GameCardMorph({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.transitionType = ContainerTransitionType.fade,
  });

  final CloseContainerBuilder closedBuilder;
  final OpenContainerBuilder<T> openBuilder;
  final ContainerTransitionType transitionType;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: OpenContainer<T>(
        transitionType: transitionType,
        openBuilder: openBuilder,
        closedBuilder: closedBuilder,
        transitionDuration: const Duration(milliseconds: 300),
        closedElevation: 0,
        openElevation: 0,
      ),
    );
  }
}
