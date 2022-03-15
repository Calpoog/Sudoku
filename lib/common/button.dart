import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../models/settings.dart';
import '../pages/sudoku/sudoku_page.dart';
import 'colors.dart';
import 'text.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.size,
    required this.child,
    required this.index,
    this.isActive = false,
    required this.onPressed,
    this.onLongPress,
    this.text,
  }) : super(key: key);

  final int index;
  final double size;
  final Widget child;
  final bool isActive;
  final String? text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? colors.accent : colors.button,
        borderRadius: BorderRadius.all(Radius.circular(size * 0.2)),
        border: Border.all(color: isActive ? colors.accent : colors.outline),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(size * 0.2)),
          splashColor: colors.accent,
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          onLongPress: onLongPress,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(child: child),
          ),
        ),
      ),
    );

    if (text != null) {
      button = Column(
        children: [
          button,
          Container(
            height: size * 0.5,
            alignment: Alignment.bottomCenter,
            child: AppText(
              text!.toUpperCase(),
              size: 12 / 50 * size,
            ),
          ),
        ],
      );
    }

    final start = 0.5 + (index - 1) * 0.02;
    final animation = CurvedAnimation(
      parent: context.read<SudokuEntryAnimation>().controller,
      curve: Interval(start, start + 0.1, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, size * 0.3 * (1 - animation.value)),
        child: Transform.scale(
          scale: 0.8 + 0.2 * animation.value,
          child: Opacity(
            opacity: animation.value,
            child: button,
          ),
        ),
      ),
    );
  }
}

class DigitButton extends StatelessWidget {
  const DigitButton({
    Key? key,
    required this.digit,
    required this.size,
  }) : super(key: key);

  final int digit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();

    return Button(
      size: size,
      index: digit - 1,
      isActive: game.activeDigit == digit,
      onPressed: () => game.activate(digit),
      onLongPress: () => game.activate(digit, true),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppText(
              digit.toString(),
              size: size * 0.6,
            ),
            if (settings.showRemainingCount)
              Positioned(
                bottom: size * 0.1,
                right: size * 0.1,
                child: Opacity(
                  opacity: 0.5,
                  child: AppText(
                    (pow(game.grid.size, 2) - game.grid.cells.where((cell) => cell.digit == digit).length).toString(),
                    size: size * 0.2,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
