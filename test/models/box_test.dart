import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/models/box.dart';


void main() {
  test('Empty box is created', () {
    Box box = Box.empty(size: 3, row:5, col: 6);
    expect(box.isEmpty(), true);
  });

  test('Non-empty box is created', () {
    Box box = Box(size: 3, row:5, col: 6, digits: [0, 1, 2, 3, 4, 5, 6, 7, 8]);
    expect(box.isEmpty(), false);
  });
}