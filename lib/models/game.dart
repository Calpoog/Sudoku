import 'package:flutter/material.dart';
import 'cell.dart';

class SudokuGame extends ChangeNotifier {
  Cell? selectedCell;
  int activeDigit = 0;

  void select(Cell cell) {
    selectedCell = cell;
    if (activeDigit > 0 && !cell.isHint) {
      cell.digit = activeDigit;
    }
    notifyListeners();
  }

  void activate(int digit) {
    if (digit == activeDigit) {
      activeDigit = 0;
    } else {
      activeDigit = digit;
      if (selectedCell != null && !selectedCell!.isHint) {
        selectedCell!.digit = digit;
      }
    }
    notifyListeners();
  }

  void clearSelected() {
    if (selectedCell != null && !selectedCell!.isHint) {
      selectedCell!.digit = 0;
    }
    activeDigit = 0;
    notifyListeners();
  }
}
