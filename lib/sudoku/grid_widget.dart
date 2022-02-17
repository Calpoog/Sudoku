import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../models/game.dart';
import '../models/grid.dart';
import 'box_widget.dart';
import 'constants.dart';
import 'grid_painter.dart';

class GridWidget extends StatelessWidget {
  const GridWidget(this.grid, {Key? key}) : super(key: key);

  final Grid grid;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize =
                ((constraints.maxWidth - kMainLineWidth * 2 - kSubLineWidth * 6) / 9).floorToDouble();
            final double boxOffset = cellSize * grid.size + kSubLineWidth * (grid.size - 1) + kMainLineWidth;
            return SizedBox(
              width: boxOffset * grid.size - kMainLineWidth,
              height: boxOffset * grid.size - kMainLineWidth,
              child: GridPainter(
                cellSize: cellSize,
                child: Stack(
                  children: grid.boxes
                      .map(
                        (box) => Positioned(
                          left: box.col * boxOffset,
                          top: box.row * boxOffset,
                          child: BoxWidget(box: box, cellSize: cellSize),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
