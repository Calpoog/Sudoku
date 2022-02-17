import 'dart:math';

import 'cell.dart';

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
  final List<Cell> cells = [];

  Box({required this.size, required this.row, required this.col, required List<Cell> cells}) {
    final cellCount = pow(size, 2).toInt();
    final offset = size * (row * cellCount + col);
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        this.cells.add(cells[offset + y * cellCount + x]);
      }
    }
  }

  // isValid checks the validity of the cells in a box - by making sure that
  //   all members exist only once.
  // Future enhancements probably include identifying which cells contain
  //   duplicate digits
  bool get isValid {
    final digits = cells.map((c) => c.digit).where((d) => d > 0);
    return digits.length == Set.from(digits).length;
  }

  bool isEmpty() {
    Cell test = cells.firstWhere((x) => x.digit > 0 && x.candidates.isNotEmpty, orElse: () => Cell(row: -1, col: -1));
    return test.row == -1;
  }

  @override
  String toString() {
    String result = '';
    for (int i = 0; i < cells.length; i++) {
      result += cells[i].digit.toString() + ((i + 1) % 3 == 0 ? '\n' : '');
    }
    return result;
  }
}
