// The Cell represents the individual squares which can contain a single
//  digit (typically from 1-9), and any candidates which the user believes the
//  cell may get
// Fields:
//  row: row that a cell sits on in a box
//  col: column that a cell sits on in a box
class Cell {
  int digit;
  Set candidates = {};
  final int row;
  final int col;

  Cell({required this.row, required this.col, this.digit = 0});

  @override
  String toString() {
    return 'Cell(row: $row, col: $col, digit: $digit)';
  }

  clearCandidates(){
    candidates = {};
  }

  clearDigit(){
    digit = 0;
  }

  // This assumes we want to delete the candidates when the user chooses a digit
  setDigit(int digit){
    clearCandidates();
    this.digit = digit;
  }

  int getDigit(){
    return digit;
  }
}
