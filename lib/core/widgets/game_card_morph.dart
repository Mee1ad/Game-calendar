import 'package:animations/animations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Wraps content in RepaintBoundary + OpenContainer for 120Hz Morph.
/// Strategy: Isolate repaints, use transform-based animation, avoid layout thrash.
class GameCardMorph<T> extends StatelessWidget {
  const GameCardMorph({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.transitionType = OpenContainerTransitionType.fade,
  });

  final ClosedBuilder closedBuilder;
  final OpenContainerBuilder openBuilder;
  final OpenContainerTransitionType transitionType;

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
