import 'box.dart';
import 'dart:math';
import 'package:collection/collection.dart';

import 'cell.dart';

// The Grid represents a collection of Boxes, all of which must have unique values
//  within themselves as well as along the rows/columns of the entire grid
// Fields:
//  size: number of rows/columns in the entire board
class Grid {
  // Number of cells is always size^(size*2)
  final int size;

  /// A list of all cells in left-right/top-bottom order.
  late final List<Cell> cells;

  /// A list of rows (list of cells) referencing the same Cell objects in `cells`
  late final List<List<Cell>> rows;

  /// A list of cols (list of cells) referencing the same Cell objects in `cells`
  late final List<List<Cell>> cols;

  /// A list of boxes referencing the same Cell objects in `cells`
  late final List<Box> boxes;

  Grid._internal({required List<int> digits, required this.size}) {
    final int count = pow(size, 2).toInt();

    // Create total cells list.
    cells = digits
        .mapIndexed(
          (index, digit) => Cell(
            col: index % count,
            row: (index / count).floor(),
            digit: digit,
          ),
        )
        .toList();

    // Generate grid boxes, passing the total list of cells and allowing the Box
    // to pull it's own is the most effective
    boxes = List<Box>.generate(
      count,
      (index) => Box(
        size: size,
        col: index % size,
        row: (index / size).floor(),
        cells: cells,
      ),
    );

    // Create list of rows from cells list
    rows = List<List<Cell>>.generate(
      count,
      (index) => cells.sublist(
        index * count,
        count * (index + 1),
      ),
    );

    // Create list of cols from cells list
    cols = List<List<Cell>>.generate(count, (index) {
      final col = <Cell>[];
      for (int i = 0; i < count; i++) {
        col.add(cells[i * count + index]);
      }
      return col;
    });
  }

  factory Grid.empty({int size = 3}) {
    return Grid._internal(digits: List.filled(pow(size, size * 2).toInt(), 0), size: size);
  }

  factory Grid.fromString(String string, {int size = 3}) {
    return Grid._internal(digits: string.split('').map((d) => int.parse(d)).toList(), size: size);
  }

  bool get isValid {
    for (var row in rows) {
      if (!_isLineValid(row)) return false;
    }
    for (var col in cols) {
      if (!_isLineValid(col)) return false;
    }
    for (var box in boxes) {
      if (!box.isValid) return false;
    }
    return true;
  }

  bool isCellValid(Cell cell) {
    if (!_isLineValid(rows[cell.row]) || !_isLineValid(cols[cell.col])) return false;
    final boxX = (cell.col / size).floor();
    final boxY = (cell.row / size).floor();
    if (!boxes[boxY * size + boxX].isValid) return false;
    return true;
  }

  bool _isLineValid(List<Cell> line) {
    final digits = line.map((c) => c.digit).where((d) => d > 0);
    return digits.length == Set.from(digits).length;
  }

  void updateCell(Cell cell) {
    cells[cell.row * size * size + cell.col].merge(cell);
  }

  @override
  String toString() {
    String result = '';
    final dimension = pow(size, 2).toInt();
    for (int y = 0; y < dimension; y++) {
      final List<String> sets = [];
      for (int x = 0; x < dimension; x += size) {
        final offset = y * dimension + x;
        sets.add(cells.sublist(offset, offset + size).map((c) => c.digit.toString()).join(' '));
      }
      if (y % size == 0) result += '---------------------\n';
      result += sets.join(' | ') + '\n';
    }
    return result;
  }
}
