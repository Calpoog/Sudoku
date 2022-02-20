import 'package:flutter/material.dart';

import 'box.dart';
import 'dart:math';
import 'package:collection/collection.dart';

import 'cell.dart';

class Line {
  final List<Cell> cells;
  final bool Function(List<Cell> cells) validator;

  Line({required this.cells, required this.validator}) {
    for (var cell in cells) {
      cell.lines.add(this);
    }
  }

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
  final List<Line> thermos = [];

  /// A list of boxes referencing the same Cell objects in `cells`
  late final List<Box> boxes;

  // TODO: The solution should be maintained separately so checking correctness of
  // individual cells for the baby bois who turn on correct-indicator mode
  Grid._internal({
    required this.cells,
    List<List<int>>? thermos,
    required this.size,
  }) {
    final int count = pow(size, 2).toInt();

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

    if (thermos != null) {
      this.thermos.addAll(
        thermos.map(
          (pairs) {
            final List<Cell> cells = [];
            for (int i = 0; i < pairs.length; i += 2) {
              final col = pairs[i];
              final row = pairs[i + 1];
              cells.add(_getCellFromPosition(row, col));
            }
            return Line(cells: cells, validator: _increasingValidator);
          },
        ),
      );
    }
  }

  _getCellFromPosition(int row, int col) {
    return cells[row * size * size + col];
  }

  // Ignore for now, this will only really be relevant when it comes to the sudoku-maker
  // factory Grid.empty({int size = 3}) {
  //   return Grid._internal(digits: List.filled(pow(size, size * 2).toInt(), 0), size: size);
  // }

  factory Grid.fromJSON(Map<String, dynamic> json, {int size = 3}) {
    return Grid._internal(
      cells: _deserealizeCells(json['cells']),
      size: size,
      thermos: json['thermos'],
    );
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
    final boxX = (cell.col / size).floor();
    final boxY = (cell.row / size).floor();
    if (!boxes[boxY * size + boxX].isValid) return false;
    // Cells store all lines they belong to (row, col, thermos, etc.)
    for (var line in cell.lines) {
      if (!line.isValid()) return false;
    }
    return true;
  }

  void updateCell(Cell cell) {
    cells[cell.row * size * size + cell.col].merge(cell);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {'cells': _serializeCells()};

    if (thermos.isNotEmpty) {
      json['thermos'] = thermos
          .map(
            (thermo) => thermo.cells.fold<List<int>>(
              [],
              (flattened, cell) {
                return flattened
                  ..add(cell.col)
                  ..add(cell.row);
              },
            ),
          )
          .toList();
    }

    return json;
  }

  String _serializeCells() {
    return cells.map((cell) {
      if (cell.digit == 0 && cell.candidates.isNotEmpty) return '[${cell.candidates.join('')}]';
      return '${cell.isClue ? 'c' : ''}${cell.digit}';
    }).join('');
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

// This outside allows the factory constructor access to them to deserealize and pass to internal
// constructor

List<Cell> _deserealizeCells(String strCells) {
  return RegExp(r'\[(\d+)\]|(c?\d)').allMatches(strCells).mapIndexed((index, match) {
    final candidates = match.group(1);
    var digit = match.group(2);
    // TODO: Still assuming 3x3
    final col = index % 9;
    final row = (index / 9).floor();

    if (candidates != null) {
      return Cell(
        row: row,
        col: col,
        candidates: candidates.split('').map((c) => int.parse(c)).toList(),
      );
    } else {
      var isClue = false;
      if (digit![0] == 'c') {
        isClue = true;
        digit = digit[1];
      }
      return Cell(row: row, col: col, digit: int.parse(digit), isClue: isClue);
    }
  }).toList();
}

bool _noDupeValidator(List<Cell> cells) {
  final digits = cells.map((c) => c.digit).where((d) => d > 0);
  return digits.length == Set.from(digits).length;
}

// This also insures no dupes just implicitly
bool _increasingValidator(List<Cell> cells) {
  final nonEmptyCells = cells.where((cell) => cell.digit > 0).toList();
  for (int i = 0; i < nonEmptyCells.length - 1; i++) {
    if (nonEmptyCells[i].digit >= nonEmptyCells[i + 1].digit) {
      return false;
    }
  }
  return true;
}
