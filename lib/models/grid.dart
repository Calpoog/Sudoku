import 'box.dart';
import 'dart:math';
import 'package:collection/collection.dart';

import 'cell.dart';

class Line {
  final List<Cell> cells;
  final bool Function(List<Cell> cells) validator;

  Line({required this.cells, required this.validator});

  bool isValid() {
    return validator(cells);
  }
}

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
  final List<Line> rows = [];

  /// A list of cols (list of cells) referencing the same Cell objects in `cells`
  final List<Line> cols = [];

  // TODO: other List<Line> for thermos, cages, etc. But keep them separate since
  // the UI will need to understand which is which for drawing purposes.

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

    // Create rows as Lines
    rows.addAll(
      List.generate(
        count,
        (index) => Line(
          cells: cells.sublist(
            index * count,
            count * (index + 1),
          ),
          validator: _noDupeValidator,
        ),
      ),
    );

    // Create columns as Lines
    cols.addAll(
      List.generate(
        count,
        (index) {
          final col = <Cell>[];
          for (int i = 0; i < count; i++) {
            col.add(cells[i * count + index]);
          }
          return Line(
            cells: col,
            validator: _noDupeValidator,
          );
        },
      ),
    );

    // TODO: thermos and cages will also be Line lists
  }

  factory Grid.empty({int size = 3}) {
    return Grid._internal(digits: List.filled(pow(size, size * 2).toInt(), 0), size: size);
  }

  factory Grid.fromString(String string, {int size = 3}) {
    return Grid._internal(digits: string.split('').map((d) => int.parse(d)).toList(), size: size);
  }

  bool get isValid {
    final lines = List.from(rows)..addAll(cols); // ..addAll(thermos)..addALl(cages)
    for (var line in lines) {
      if (!line.isValid()) return false;
    }
    for (var box in boxes) {
      if (!box.isValid) return false;
    }
    return true;
  }

  /// Checks only the validity of a [Cell] based on the rows/cols/boxes/thermos/cages it is in
  bool isCellValid(Cell cell) {
    // TODO: we'd have to figure out which thermos/cages it's in to check only the ones that matter
    if (!rows[cell.row].isValid() || !cols[cell.col].isValid()) return false;
    final boxX = (cell.col / size).floor();
    final boxY = (cell.row / size).floor();
    if (!boxes[boxY * size + boxX].isValid) return false;
    return true;
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

bool _noDupeValidator(List<Cell> cells) {
  final digits = cells.map((c) => c.digit).where((d) => d > 0);
  return digits.length == Set.from(digits).length;
}
