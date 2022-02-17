import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/models/box.dart';
import 'package:sudoku/models/cell.dart';

final cells = '004300209005009001070060043006002087190007400050083000600000105003508690042910300'
    .split('')
    .map(
      (d) => Cell(
        row: 0,
        col: 0,
        digit: int.parse(d),
      ),
    )
    .toList();

void main() {
  group('Box', () {
    test('Box takes the correct cells from overall list', () {
      // test a few
      Box box = Box(size: 3, row: 1, col: 1, cells: cells);
      expect(box.cells.map((e) => e.digit).join(), '002007083');

      box = Box(size: 3, row: 2, col: 2, cells: cells);
      expect(box.cells.map((e) => e.digit).join(), '105690300');

      box = Box(size: 3, row: 0, col: 2, cells: cells);
      expect(box.cells.map((e) => e.digit).join(), '209001043');
    });

    test('is valid', () {
      Box box = Box(size: 3, row: 1, col: 1, cells: cells);
      expect(box.isValid, true);
    });

    test('is invalid with a repeated digit', () {
      Box box = Box(size: 3, row: 1, col: 1, cells: cells);
      box.cells[3].digit = 2;
      expect(box.isValid, false);
      box.cells[3].digit = 0;
      expect(box.isValid, true);
    });
  });
}
