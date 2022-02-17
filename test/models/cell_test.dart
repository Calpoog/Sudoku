import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/models/cell.dart';

void main() {
  test('Cell 5,6 is created and has 0 as its default value', () {
    Cell cell = Cell(row: 5, col: 6);
    expect(cell.digit, 0);
  });

  test('Cell 0,1 is created and its candidates are added', () {
    Cell cell = Cell(row: 0, col: 1);
    cell.candidates.add(4);
    cell.candidates.addAll([5, 7, 8]);
    expect(cell.candidates.containsAll([4, 5, 7, 8]), true);
  });

  test('Cell candidates cannot have duplicate values', () {
    Cell cell = Cell(row: 0, col: 1);
    cell.candidates.add(2);
    expect(cell.candidates.add(2), false);
  });

  test('Setting a cell digit clears out the candidates', () {
    Cell cell = Cell(row: 0, col: 1);
    cell.candidates.addAll([1, 7, 9]);
    cell.digit = 5;
    expect(cell.candidates.isEmpty, true);
  });
}
