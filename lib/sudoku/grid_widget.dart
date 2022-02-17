import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../models/grid.dart';
import 'box_widget.dart';
import 'constants.dart';

class GridWidget extends StatelessWidget {
  const GridWidget(this.grid, {Key? key}) : super(key: key);

  final Grid grid;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: colors.accent,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize =
                ((constraints.maxWidth - kMainLineWidth * 2 - kSubLineWidth * 6) / 9).floorToDouble();
            final double boxOffset = cellSize * grid.size + kSubLineWidth * (grid.size - 1) + kMainLineWidth;
            return SizedBox(
              width: boxOffset * grid.size - kMainLineWidth,
              height: boxOffset * grid.size - kMainLineWidth,
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
            );
          },
        ),
      ),
    );
  }
}
