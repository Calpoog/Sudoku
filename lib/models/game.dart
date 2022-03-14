import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../pages/sudoku/clock.dart';
import '../utils/saves.dart';
import 'cell.dart';
import 'grid.dart';

class SudokuGame extends ChangeNotifier {
  final Grid grid;
  Cell? selectedCell;
  int activeDigit = 0;
  bool isPenciling = false;
  // I'm adding titles to games, but we don't need to keep this. I can change
  //   loadGame to return a Map<String, SudokuGame> instead, we can decide later
  final String title;
  final String id;
  final DateTime? lastPlayed;
  late final PlayTimer timer;

  // History is a list of copied cells (before its state is updated)
  final List<Cell> history = [];

  SudokuGame._internal({
    String? title,
    required this.grid,
    this.lastPlayed,
    required this.id,
    int initialSeconds = 0,
  }) : title = title ?? '' {
    timer = PlayTimer(initialSeconds);
  }

  factory SudokuGame.hardcoded() {
    return SudokuGame._internal(
      title: DateTime.now().toString(),
      grid: Grid.fromJSON({
        'cells':
            '0[1234]c4c301c20c900c500c900c10c700c600c4c300c600c20c8c7c1c9000c7c4000c500c8c3000c600000c10c500c3c50c8c6c900c4c2c9c10c300',
        'solution': '864371259325849761971265843436192587198657432257483916689734125713528694542916378',
      }),
      id: const Uuid().v4(),
    );
  }

  static Future<SudokuGame> create(int clues) async {
    return SudokuGame._internal(
      title: DateTime.now().toString(),
      grid: await Grid.generate(clues),
      id: const Uuid().v4(),
    );
  }

  void resumeTimer() {
    timer.start();
  }

  void stopTimer() {
    timer.stop();
  }

  void togglePencil() {
    isPenciling = !isPenciling;
    notifyListeners();
  }

  /// Checks if the board is valid
  bool check() {
    final isComplete = grid.check();
    notifyListeners();
    return isComplete;
  }

  void solve() {
    grid.solve();
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

  void move(int col, int row) {
    selectedCell = grid.cellAt(col, row);
    notifyListeners();
  }

  void up() {
    if (selectedCell == null) return;
    move(selectedCell!.col, max(0, selectedCell!.row - 1));
  }

  void down() {
    if (selectedCell == null) return;
    move(selectedCell!.col, min(grid.size * grid.size - 1, selectedCell!.row + 1));
  }

  void left() {
    if (selectedCell == null) return;
    move(max(0, selectedCell!.col - 1), selectedCell!.row);
  }

  void right() {
    if (selectedCell == null) return;
    move(min(grid.size * grid.size - 1, selectedCell!.col + 1), selectedCell!.row);
  }

  void activate(int digit, [bool keepActive = false]) {
    if (digit == activeDigit) {
      activeDigit = 0;
    } else {
      activeDigit = keepActive ? digit : 0;
      if (selectedCell != null && !selectedCell!.isClue) {
        if (isPenciling) {
          if (selectedCell!.digit == 0) _toggleCandidate(digit);
        } else {
          _setDigit(selectedCell!, digit);
        }
      }
    }
    notifyListeners();
  }

  void clearCell({Cell? cell, bool notify = true, bool select = true}) {
    if (cell != null && !cell.isClue) {
      cell.clear();
      // this duplicates setting digit to 0 but also deals with history
      _setDigit(cell, 0);
      if (select) selectedCell = cell;
    } else if (selectedCell != null && !selectedCell!.isClue) {
      _setDigit(selectedCell!, 0);
    }
    activeDigit = 0;
    if (notify) notifyListeners();
  }

  void restart() {
    for (var cell in grid.cells) {
      clearCell(cell: cell, notify: false, select: false);
    }
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
    cell.candidates.contains(digit) ? cell.candidates.remove(digit) : cell.candidates.add(digit);
  }

  void _setDigit(Cell cell, int digit) {
    // TODO: setting that clears set digit from candidates that would be eliminated (in box/row/col)
    pushHistory(cell);
    cell.digit = digit;
    debugPrint('Valid: ${grid.isValid}');
    final json = grid.toJSON();
    debugPrint(json.toString());
  }

  void pushHistory(Cell cell) {
    history.add(cell.copyWith());
    ManageSaves.saveGame(this);
  }

  Map<String, dynamic> toJSON() {
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    return {
      'lastPlayed': currentTime,
      'title': title,
      'grid': grid.toJSON(),
      'id': id,
      'playTime': timer.currentDuration.inSeconds,
    };
  }

  factory SudokuGame.fromJSON(Map<String, dynamic> json) {
    return SudokuGame._internal(
      grid: Grid.fromJSON(json['grid']),
      title: json['title'],
      lastPlayed: DateTime.fromMillisecondsSinceEpoch(json['lastPlayed']),
      id: json['id'],
      initialSeconds: json['playTime'],
    );
  }

  save() {
    ManageSaves.saveGame(this);
  }
}
