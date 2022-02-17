import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../models/box.dart';
import 'cell_widget.dart';
import 'constants.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({Key? key, required this.box, required this.cellSize}) : super(key: key);

  final Box box;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final size = cellSize * box.size + (box.size - 1) * kSubLineWidth;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.read<ThemeColors>().line,
      ),
      child: Stack(
        children: box.cells
            .map(
              (cell) => Positioned(
                left: (cell.col - box.col * box.size) * (cellSize + kSubLineWidth),
                top: (cell.row - box.row * box.size) * (cellSize + kSubLineWidth),
                child: CellWidget(cell, size: cellSize),
              ),
            )
            .toList(),
      ),
    );
  }
}
