// The Cell represents the individual squares which can contain a single
//  digit (typically from 1-9), and any candidates which the user believes the
//  cell may get
// Fields:
//  row: row that a cell sits on in a box
//  col: column that a cell sits on in a box
import 'dart:collection';

import 'grid.dart';
import 'settings.dart';

class Cell {
  int _digit;
  bool isClue;
  final candidates = SplayTreeSet<int>();
  final int row;
  final int col;

  /// Whether this cell has been marked as invalid.
  ///
  /// The player can check validity, and if the settings to show invalid cells
  /// after check is true, incorrect cells will be visually shown. This is reset
  /// when they modify the cell in any way.
  bool markedInvalid;

  /// The lines (thermos, german whisper, etc.) this cell belongs to
  final List<Line> lines = [];

  Cell({
    required this.row,
    required this.col,
    int digit = 0,
    List<int>? candidates,
    this.isClue = false,
    this.markedInvalid = false,
  }) : _digit = digit {
    if (candidates != null) this.candidates.addAll(candidates);
  }

  @override
  String toString() {
    return 'Cell(row: $row, col: $col, digit: $digit, isClue: $isClue, candidates: $candidates)';
  }

  clear() {
    if (digit == 0) {
      candidates.clear();
    }
    digit = 0;
  }

  // This assumes we want to delete the candidates when the user chooses a digit
  set digit(int digit) {
    if (settings.clearPencilOnDigit) {
      candidates.clear();
    }
    markedInvalid = false;
    _digit = digit;
  }

  int get digit => _digit;

  /// Create a new [Cell] using an optional digit and candidates override.
  ///
  /// Used in creating a copy of a [Cell] for history.
  Cell copyWith({int? digit, List<int>? candidates}) {
    return Cell(
      row: row,
      col: col,
      digit: digit ?? this.digit,
      candidates: candidates,
      isClue: isClue,
    );
  }

  /// Merges in the digit and candidates from another [Cell].
  ///
  /// Used in reverting a [Cell] from a history copy.
  void merge(Cell other) {
    digit = other.digit;
    candidates
      ..clear()
      ..addAll(other.candidates);
    isClue = other.isClue;
  }
}
