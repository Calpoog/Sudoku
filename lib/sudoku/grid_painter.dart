import 'package:flutter/material.dart';

import '../colors.dart';
import 'constants.dart';

class BoardPainter extends CustomPainter {
  final double cellSize;
  final ThemeColors colors;

  BoardPainter(this.cellSize, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = 6 * kSubLineWidth + 2 * kMainLineWidth + 9 * cellSize;
    var paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = colors.line;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i <= 8; i++) {
        if (i % 3 == 0) continue;
        final x = i * (cellSize + 1) + (i / 3).floor();
        if (flip == 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, boardSize), paint);
        } else {
          canvas.drawLine(Offset(0, x), Offset(boardSize, x), paint);
        }
      }
    }

    paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = colors.accent;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i <= 2; i++) {
        final x = i * (cellSize * 3 + 3);
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
