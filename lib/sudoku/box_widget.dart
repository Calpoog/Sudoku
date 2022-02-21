import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../models/box.dart';
import 'cell_widget.dart';
import 'constants.dart';

class BoxWidget extends StatelessWidget {
  const BoxWidget({Key? key, required this.box, required this.cellSize, this.isPreview = false}) : super(key: key);

  final Box box;
  final double cellSize;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final size = cellSize * box.size + (box.size - 1) * kSubLineWidth;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: box.cells
            .map(
              (cell) => Positioned(
                left: (cell.col - box.col * box.size) * (cellSize + kSubLineWidth),
                top: (cell.row - box.row * box.size) * (cellSize + kSubLineWidth),
                child: CellWidget(
                  cell,
                  size: cellSize,
                  isPreview: isPreview,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
