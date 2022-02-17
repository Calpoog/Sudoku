import 'package:flutter/material.dart';
import 'cell.dart';
import 'grid.dart';

class SudokuGame extends ChangeNotifier {
  Grid grid = Grid.fromString('004300209005009001070060043006002087190007400050083000600000105003508690042910300');
  Cell? selectedCell;
  int activeDigit = 0;
  bool isPenciling = false;

  void togglePencil() {
    isPenciling = !isPenciling;
    notifyListeners();
  }

  void select(Cell cell) {
    if (selectedCell == cell) {
      selectedCell = null;
    } else {
      selectedCell = cell;
      if (activeDigit > 0) {
        if (isPenciling) {
          _toggleCandidate(activeDigit);
        } else if (!cell.isClue) {
          cell.digit = activeDigit;
        }
      }
    }
    notifyListeners();
  }

  void activate(int digit) {
    if (digit == activeDigit) {
      activeDigit = 0;
    } else {
      activeDigit = digit;
      if (selectedCell != null && !selectedCell!.isClue) {
        if (isPenciling) {
          _toggleCandidate(digit);
        } else {
          selectedCell!.digit = digit;
        }
      }
    }
    notifyListeners();
  }

  void _toggleCandidate(int digit) {
    if (selectedCell == null) return;
    final cell = selectedCell!;
    cell.candidates.contains(activeDigit) ? cell.candidates.remove(activeDigit) : cell.candidates.add(activeDigit);
  }

  void clearSelected() {
    if (selectedCell != null && !selectedCell!.isClue) {
      selectedCell!.digit = 0;
    }
    activeDigit = 0;
    notifyListeners();
  }
}
