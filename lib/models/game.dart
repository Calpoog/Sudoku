import 'package:flutter/material.dart';
import 'cell.dart';
import 'grid.dart';

class SudokuGame extends ChangeNotifier {
  Grid grid = Grid.fromString('004300209005009001070060043006002087190007400050083000600000105003508690042910300');
  Cell? selectedCell;
  int activeDigit = 0;
  bool isPenciling = false;
  // I'm adding titles to games, but we don't need to keep this. I can change
  //   loadGame to return a Map<String, SudokuGame> instead, we can decide later
  String title = '';

  // History is a list of copied cells (before its state is updated)
  final List<Cell> history = [];

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
          _setDigit(cell, activeDigit);
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
          _setDigit(selectedCell!, digit);
        }
      }
    }
    notifyListeners();
  }

  void clearSelected() {
    if (selectedCell != null && !selectedCell!.isClue) {
      _setDigit(selectedCell!, 0);
    }
    activeDigit = 0;
    notifyListeners();
  }

  void undo() {
    if (history.isNotEmpty) {
      final cell = history.removeLast();
      grid.updateCell(cell);
      notifyListeners();
    }
  }

  void _toggleCandidate(int digit) {
    if (selectedCell == null) return;
    final cell = selectedCell!;
    pushHistory(cell);
    cell.candidates.contains(activeDigit) ? cell.candidates.remove(activeDigit) : cell.candidates.add(activeDigit);
  }

  void _setDigit(Cell cell, int digit) {
    pushHistory(cell);
    cell.digit = digit;
    debugPrint('Valid: ${grid.isValid}');
  }

  void pushHistory(Cell cell) {
    history.add(cell.copyWith());
  }
}
