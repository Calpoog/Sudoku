import 'package:sudoku/models/box.dart';
import 'dart:math';

// The Grid represents a collection of Boxes, all of which must have unique values
//  within themselves as well as along the rows/columns of the entire grid
// Fields:
//  size: number of rows/columns in the entire board
class Grid {
  // Number of cells is always size^(size*2)
  final int size;
  late List<Box> boxes;

  Grid({this.size = 3}) {
    final int _boxCount = pow(size, 2).toInt();
    boxes = List<Box>.generate(
      _boxCount,
      (int index) => Box(
          size: size,
          row:(index % size).toInt(),
          col:(index/size).floor()
      )
    );
  }
}
