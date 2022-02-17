import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/cell.dart';
import '../models/game.dart';

class CellWidget extends StatelessWidget {
  const CellWidget(this.cell, {Key? key, required this.size}) : super(key: key);

  final Cell cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final isSelected = game.selectedCell == cell;
    return GestureDetector(
      onTap: () {
        game.select(cell);
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.background,
        ),
        child: AppText(
          cell.digit.toString().replaceAll('0', ''),
          size: size * 0.5,
          // weight: FontWeight.w300,
        ),
      ),
    );
  }
}
