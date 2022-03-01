import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../models/cell.dart';
import '../models/game.dart';
import '../models/grid.dart';
import '../models/settings.dart';
import 'constants.dart';

class GridPainter extends StatelessWidget {
  const GridPainter({Key? key, required this.cellSize, required this.child}) : super(key: key);

  final double cellSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    final game = context.watch<SudokuGame>();
    return CustomPaint(
      child: child,
      painter: GridCustomPainter(
        cellSize: cellSize,
        grid: game.grid,
        selectedCell: game.selectedCell,
        colors: colors,
        settings: context.watch<Settings>(),
      ),
    );
  }
}

class GridCustomPainter extends CustomPainter {
  final double cellSize;
  final Grid grid;
  final ThemeColors colors;
  final Cell? selectedCell;
  final Settings settings;

  GridCustomPainter({
    required this.cellSize,
    required this.grid,
    required this.selectedCell,
    required this.colors,
    required this.settings,
  });

  double _getOffset(int i) {
    final mainLineOffset = (i / grid.size).floor() * (kMainLineWidth - kSubLineWidth);
    return i * (cellSize + kSubLineWidth) - kSubLineWidth / 2 + mainLineOffset;
  }

  Offset _getCellCenter(Cell cell) {
    return Offset(_getOffset(cell.col) + cellSize / 2, _getOffset(cell.row) + cellSize / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.width;
    final gridSize = grid.size;

    var paint = Paint()..color = colors.indicatorDark.withOpacity(0.3);

    if (settings.highlightRowColumn && selectedCell != null) {
      canvas.drawRect(Rect.fromLTWH(_getOffset(selectedCell!.col), 0, cellSize, boardSize), paint);
      canvas.drawRect(Rect.fromLTWH(0, _getOffset(selectedCell!.row), boardSize, cellSize), paint);
    }

    paint = Paint()
      ..strokeWidth = cellSize / 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colors.indicatorLight;

    for (var thermo in grid.thermos) {
      canvas.drawCircle(_getCellCenter(thermo.cells.first), cellSize / 3.5, paint);
      canvas.drawPoints(
        PointMode.polygon,
        thermo.cells.map((cell) => _getCellCenter(cell)).toList(),
        paint,
      );
    }

    paint = Paint()
      ..strokeWidth = kSubLineWidth
      ..strokeCap = StrokeCap.round
      ..color = colors.line;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i < gridSize * gridSize; i++) {
        if (i % gridSize == 0) continue;
        final x = _getOffset(i);
        if (flip == 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, boardSize), paint);
        } else {
          canvas.drawLine(Offset(0, x), Offset(boardSize, x), paint);
        }
      }
    }

    paint = Paint()
      ..strokeWidth = kMainLineWidth
      ..strokeCap = StrokeCap.round
      ..color = colors.accent;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i <= gridSize - 1; i++) {
        final x = i * (gridSize * cellSize + kSubLineWidth * (gridSize - 1) + kMainLineWidth / 2) + i - 1;
        if (flip == 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, boardSize), paint);
        } else {
          canvas.drawLine(Offset(0, x), Offset(boardSize, x), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
