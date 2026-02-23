import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
        closedColor: Colors.transparent,
        openColor: Theme.of(context).colorScheme.surface,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
