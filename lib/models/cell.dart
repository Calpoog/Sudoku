// The Cell represents the individual squares which can contain a single
//  digit (typically from 1-9), and any candidates which the user believes the
//  cell may get
// Fields:
//  row: row that a cell sits on in a box
//  col: column that a cell sits on in a box
class Cell {
  int digit = 0;
  var candidates = [];
  int row = -1;
  int col = -1;

  Cell({required this.row, required this.col});

}