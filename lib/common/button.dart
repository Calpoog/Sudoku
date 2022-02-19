import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import 'colors.dart';
import 'text.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.size,
    required this.child,
    this.isActive = false,
    required this.onPressed,
    this.onLongPress,
    this.text,
  }) : super(key: key);

  final double size;
  final Widget child;
  final bool isActive;
  final String? text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? colors.accent : colors.button,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: isActive ? colors.accent : colors.outline),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
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
      return Column(
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
    return button;
  }
}

class DigitButton extends StatelessWidget {
  const DigitButton({Key? key, required this.digit, required this.size}) : super(key: key);

  final int digit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    return Button(
      size: size,
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
