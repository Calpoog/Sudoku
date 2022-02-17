// The Cell represents the individual squares which can contain a single
//  digit (typically from 1-9), and any candidates which the user believes the
//  cell may get
// Fields:
//  row: row that a cell sits on in a box
//  col: column that a cell sits on in a box
import 'dart:collection';

class Cell {
  int _digit;
  final bool isClue;
  final candidates = SplayTreeSet<int>();
  final int row;
  final int col;

  Cell({required this.row, required this.col, int digit = 0})
      : _digit = digit,
        isClue = digit != 0;

  @override
  String toString() {
    return 'Cell(row: $row, col: $col, digit: $digit)';
  }

  clear() {
    digit = 0;
    // TODO: check for some kind of 'clear candidates' option
    candidates.clear();
  }

  // This assumes we want to delete the candidates when the user chooses a digit
  set digit(int digit) {
    // TODO: check for some kind of 'clear candidates' option
    candidates.clear();
    _digit = digit;
  }

  int get digit => _digit;

  /// Create a new [Cell] using an optional digit and candidates override.
  ///
  /// Used in creating a copy of a [Cell] for history.
  Cell copyWith({int? digit, List<int>? candidates}) {
    final newCell = Cell(row: row, col: col, digit: digit ?? this.digit);
    newCell.candidates.addAll(candidates ?? this.candidates);
    return newCell;
  }

  /// Merges in the digit and candidates from another [Cell].
  ///
  /// Used in reverting a [Cell] from a history copy.
  void merge(Cell other) {
    digit = other.digit;
    candidates
      ..clear()
      ..addAll(other.candidates);
  }
}
