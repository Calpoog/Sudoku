import 'dart:math';

import 'package:sudoku/models/cell.dart';

// The Box represents a collection of Cells, all of which must have a unique
//  digit (usually from 1-9) inside, for a given box to be valid
// Fields:
//  size: number of rows/columns inside the box
//  row: row that a box exists in on a grid
//  col: column that a box exists in on a grid
class Box {
  final int row;
  final int col;
  final int size;
  late List<Cell> cells;
  Box({required this.size, required this.row, required this.col}){
    final int _cellCount = pow(size, 2).toInt();
    cells = List<Cell>.generate(
      _cellCount,
      (int index) => Cell(
        row:(index % size).toInt()+row*size,
        col:(index/size).floor()+col*size
      )
    );
  }
}