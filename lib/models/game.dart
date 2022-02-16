import 'package:flutter/material.dart';
import 'package:sudoku/models/cell.dart';

class SudokuGame extends ChangeNotifier {
  Cell? selectedCell;
  int activeDigit = 0;

  void select(Cell cell) {
    selectedCell = cell;
    notifyListeners();
  }

  void activate(int digit) {
    if (digit == activeDigit) {
      activeDigit = 0;
    } else {
      activeDigit = digit;
    }
    notifyListeners();
  }
}
