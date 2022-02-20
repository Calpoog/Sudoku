import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'clock.dart';

class SudokuHeader extends StatelessWidget {
  const SudokuHeader({
    Key? key,
    required this.contentWidth,
    required this.height,
  }) : super(key: key);

  final double height;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: DefaultTextStyle(
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        child: Container(
          width: contentWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SvgPicture.asset('assets/icons/back.svg', semanticsLabel: 'Back to menu'),
              Clock(size: height * 0.3),
            ],
          ),
        ),
      ),
    );
  }
}
