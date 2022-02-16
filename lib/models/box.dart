import 'dart:math';

import 'package:sudoku/models/cell.dart';

class Box {
  final int row;
  final int col;
  final num size;
  late List<Cell> cells;
  Box({required this.size, required this.row, required this.col}){
    final int _cellCount = pow(size, 2).toInt();
    cells = List<Cell>.generate(_cellCount, (int index) => Cell(row:(index % size).toInt(),  col:(index/size).floor()));
  }
}