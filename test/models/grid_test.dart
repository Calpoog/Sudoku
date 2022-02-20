import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/cell.dart';

import 'package:sudoku/models/grid.dart';

const gridString =
    '0[1234]c4c301c20c900c500c900c10c700c600c4c300c600c20c8c7c1c9000c7c4000c500c8c3000c600000c10c500c3c50c8c6c900c4c2c9c10c300';

void main() {
  group('Grid', () {
    final grid = Grid.fromJSON({
      'cells': gridString,
      'thermos': [
        [0, 0, 1, 1, 0, 2],
        [0, 4, 6, 4]
      ]
    });
    final currentCells = gridString.replaceAll(RegExp(r'\[\d+\]'), '0').replaceAll('c', '');

    test('has the right number of contents', () {
      expect(grid.cells.length, 81);
      expect(grid.rows.length, 9);
      expect(grid.cols.length, 9);
      expect(grid.boxes.length, 9);
    });

    test('deserealized clues', () {
      expect(grid.cells[2].isClue, true);
    });

    test('deserealized candidates', () {
      var candies = grid.cells[1].candidates;
      expect(candies.contains(1), true);
      expect(candies.contains(2), true);
      expect(candies.contains(3), true);
      expect(candies.contains(4), true);
    });

    test('has the correct rows', () {
      for (int i = 0; i < 9; i++) {
        final row = grid.rows[i];
        expect(row.cells.map((c) => c.digit).join(''), currentCells.substring(i * 9, (i + 1) * 9));
      }
    });

    test('has the correct cols', () {
      final expectations = [
        '000010600',
        '007095004',
        '450600032',
        '300000059',
        '006008001',
        '190273080',
        '200040163',
        '004800090',
        '913700500',
      ];
      for (int i = 0; i < 9; i++) {
        final col = grid.cols[i];
        expect(col.cells.map((c) => c.digit).join(''), expectations[i]);
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
      // set it back to 1 because it's 1 initially in above string
      grid.cells[5].digit = 1;
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

    test('serializes correctly', () {
      final json = grid.toJSON();
      expect(json['cells'], equals(gridString));
      expect(json['thermos'].length, 2);
      expect(json['thermos'][0].length, 6);
      expect(json['thermos'][1].length, 4);
    });

    test('creates thermos from json', () {
      Cell c = grid.thermos.first.cells.first;
      expect(c.col, 0);
      expect(c.row, 0);
      expect(c.digit, 0);
      c = grid.thermos.first.cells[2];
      expect(c.col, 0);
      expect(c.row, 2);
      expect(c.digit, 0);
      c = grid.thermos[1].cells[1];
      expect(c.col, 6);
      expect(c.row, 4);
      expect(c.digit, 4);
    });
  });
}
