import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'colors.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    Key? key,
    this.size,
    this.weight,
    this.uppercase = false,
    this.letterSpacing,
  }) : super(key: key);

  const AppText.title(this.text, {Key? key})
      : size = 20,
        uppercase = true,
        weight = FontWeight.w500,
        letterSpacing = 2,
        super(key: key);

  final String text;
  final double? size;
  final FontWeight? weight;
  final double? letterSpacing;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context);
    return Text(
      uppercase ? text.toUpperCase() : text,
      style: TextStyle(
        color: context.read<ThemeColors>().text,
        fontSize: size ?? style.style.fontSize,
        fontWeight: weight ?? style.style.fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
