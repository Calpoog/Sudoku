import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/models/grid.dart';
import 'package:sudoku/models/cell.dart';

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
        expect(row.cells.map((c) => c.digit).join(''), gridString.substring(i * 9, (i + 1) * 9));
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

    test('serializes correctly', () {
      Cell candies = grid.cells[0].copyWith(candidates: [1,2,5,8]);
      Cell digies = grid.cells[5].copyWith(digit: 1);
      grid.updateCell(candies);
      grid.updateCell(digies);
      String serialized='{1258},0,c4,c3,0,1,c2,0,c9,0,0,c5,0,0,c9,0,0,c1,0,c7,0,0,'
          'c6,0,0,c4,c3,0,0,c6,0,0,c2,0,c8,c7,c1,c9,0,0,0,c7,c4,0,0,0,c5,0,0,'
          'c8,c3,0,0,0,c6,0,0,0,0,0,c1,0,c5,0,0,c3,c5,0,c8,c6,c9,0,0,c4,c2,c9,'
          'c1,0,c3,0,0';
      expect(grid.serialize(), equals(serialized));
    });

    test('deserializes correctly', () {
      //This is what a serialized grid will look like. The c represents an original
      //   clue, curlies represent a list of potentials. Max grid size 1kb :)
      String serialized='{1258},0,c4,c3,0,1,c2,0,c9,0,0,c5,0,0,c9,0,0,c1,0,c7,0,0,'
          'c6,0,0,c4,c3,0,0,c6,0,0,c2,0,c8,c7,c1,c9,0,0,0,c7,c4,0,0,0,c5,0,0,'
          'c8,c3,0,0,0,c6,0,0,0,0,0,c1,0,c5,0,0,c3,c5,0,c8,c6,c9,0,0,c4,c2,c9,'
          'c1,0,c3,0,0';
      Grid fromSerial = Grid.deSerialize(serialized);
      List<int> candies = [1, 2, 5, 8];
      expect(fromSerial.cells[0].candidates, candies);
      expect(fromSerial.cells[0].isClue, false);
      expect(fromSerial.cells[1].digit, 0);
      expect(fromSerial.cells[1].isClue, false);
      expect(fromSerial.cells[5].digit, 1);
      expect(fromSerial.cells[5].isClue, false);
      expect(fromSerial.cells[2].digit, 4);
      expect(fromSerial.cells[2].isClue, true);
    });
  });
}
