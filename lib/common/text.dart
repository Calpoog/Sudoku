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
    this.color,
  }) : super(key: key);

  const AppText.title(this.text, {Key? key})
      : size = 20,
        uppercase = true,
        weight = FontWeight.w500,
        letterSpacing = 2,
        color = null,
        super(key: key);

  final String text;
  final double? size;
  final FontWeight? weight;
  final double? letterSpacing;
  final bool uppercase;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context);
    final colors = context.read<ThemeColors>();
    return Text(
      uppercase ? text.toUpperCase() : text,
      style: TextStyle(
        color: color ?? colors.text,
        fontSize: size ?? style.style.fontSize,
        fontWeight: weight ?? style.style.fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
