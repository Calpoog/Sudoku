import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';

class AppText extends StatelessWidget {
  const AppText(this.text, {Key? key, this.size, this.weight}) : super(key: key);

  final String text;
  final double? size;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context);
    return Text(
      text,
      style: TextStyle(
        color: context.read<ThemeColors>().text,
        fontSize: size ?? style.style.fontSize,
        fontWeight: weight ?? style.style.fontWeight,
      ),
    );
  }
}
