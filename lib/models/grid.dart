import 'box.dart';
import 'dart:math';

// The Grid represents a collection of Boxes, all of which must have unique values
//  within themselves as well as along the rows/columns of the entire grid
// Fields:
//  size: number of rows/columns in the entire board
class Grid {
  // Number of cells is always size^(size*2)
  final int size;
  late List<Box> boxes;

  Grid._internal({required List<int> digits, required this.size}) {
    final int count = pow(size, 2).toInt();
    boxes = List<Box>.generate(
      count,
      (int index) => Box(
        size: size,
        col: index % size,
        row: (index / size).floor(),
        digits: digits.sublist(index * count, count * (index + 1)),
      ),
    );
  }

  Grid.empty({this.size = 3}) {
    boxes = List<Box>.generate(
      pow(size, 2).toInt(),
      (int index) => Box.empty(size: size, row: index % size, col: (index / size).floor()),
    );
  }

  factory Grid.fromString(String string, {int size = 3}) {
    final boxCellCount = pow(size, 2).toInt();
    final boxCells = List.generate(boxCellCount.toInt(), (index) => <int>[]);
    for (int y = 0; y < boxCellCount; y++) {
      final row =
          string.substring(y * boxCellCount, boxCellCount * (y + 1)).split('').map((s) => int.parse(s)).toList();
      for (int i = 0; i < size; i++) {
        final boxIndex = i + (y / size).floor() * size;
        boxCells[boxIndex].addAll(row.sublist(i * size, size * (i + 1)));
      }
    }
    final digits = boxCells.fold<List<int>>([], (previousValue, box) => previousValue..addAll(box));
    return Grid._internal(digits: digits, size: size);
  }

  @override
  String toString() {
    String result = '';
    final dimension = pow(size, 2);
    for (int y = 0; y < dimension; y++) {
      final boxY = (y / size).floor();
      for (int x = 0; x < dimension; x++) {
        final boxX = (x / size).floor();
        final boxIndex = boxY * size + boxX;
        result +=
            ' ' + boxes[boxIndex].cells.firstWhere((cell) => cell.row == y && cell.col == x).digit.toString() + ' ';
        if ((x + 1) % size == 0) result += '|';
      }
      if (y > 0 && (y + 1) % size == 0) result += '\n------------------------------';
      result += '\n';
    }
    return result;
  }
}
