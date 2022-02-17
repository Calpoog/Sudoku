import 'package:flutter/material.dart';
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
    this.onPressed,
    this.text,
  }) : super(key: key);

  final double size;
  final Widget child;
  final bool isActive;
  final String? text;
  final VoidCallback? onPressed;

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
          onTap: onPressed,
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
          const SizedBox(height: 7.0),
          AppText(
            text!.toUpperCase(),
            size: 12 / 50 * size,
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
      child: Stack(
        children: [
          AppText(
            digit.toString(),
            size: 32.0,
          )
        ],
      ),
    );
  }
}
