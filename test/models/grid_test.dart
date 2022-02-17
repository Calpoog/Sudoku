import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/models/grid.dart';

const gridString = '004300209005009001070060043006002087190007400050083000600000105003508690042910300';

void main() {
  group('Grid', () {
    final grid = Grid.fromString(gridString);

    test('has the right number of contents', () {
      expect(grid.cells.length, 81);
      expect(grid.rows.length, 9);
      expect(grid.cols.length, 9);
      expect(grid.boxes.length, 9);
    });

    test('has the correct rows', () {
      for (int i = 0; i < 9; i++) {
        final row = grid.rows[i];
        expect(row.map((c) => c.digit).join(''), gridString.substring(i * 9, (i + 1) * 9));
      }
    });

    test('has the correct cols', () {
      final expectations = [
        '000010600',
        '007095004',
        '450600032',
        '300000059',
        '006008001',
        '090273080',
        '200040163',
        '004800090',
        '913700500',
      ];
      for (int i = 0; i < 9; i++) {
        final col = grid.cols[i];
        expect(col.map((c) => c.digit).join(''), expectations[i]);
      }
    });

    test('is valid', () {
      expect(grid.isValid, true);
    });

    test('is invalid when a row is invalid', () {
      grid.cells[9].digit = 9;
      expect(grid.isValid, false);
      grid.cells[9].digit = 0;
      expect(grid.isValid, true);
    });

    test('is invalid when a col is invalid', () {
      grid.cells[4].digit = 8;
      expect(grid.isValid, false);
      grid.cells[4].digit = 0;
      expect(grid.isValid, true);
    });

    test('is invalid when a box is invalid', () {
      grid.cells[5].digit = 6;
      expect(grid.isValid, false);
      expect(grid.boxes[1].isValid, false);
      grid.cells[5].digit = 0;
      expect(grid.isValid, true);
    });

    test('can test the validity of individual cells', () {
      final cell = grid.cells[0];
      expect(grid.isCellValid(cell), true);
      // col invalid
      cell.digit = 1;
      expect(grid.isCellValid(cell), false);
      // row invalid
      cell.digit = 2;
      expect(grid.isCellValid(cell), false);
      // box invalid
      cell.digit = 7;
      expect(grid.isCellValid(cell), false);
      cell.digit = 0;
      expect(grid.isCellValid(cell), true);
    });
  });
}
