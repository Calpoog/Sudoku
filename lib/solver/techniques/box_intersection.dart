import 'technique.dart';
import '../solver.dart';

extension BoxIntersectionExtension on Solution {
  Technique? pointingPairs() {
    for (var b = 0; b < boxes.length; b++) {
      final box = boxes[b];
      // A list where the index corresponds to a digit, and the values tell which row/col it's in
      // 0, single-row: 2, 3, 4 multi-row: 5, 6, 7, 9
      final dRows = List.filled(9, 0);
      final dCols = List.filled(9, 0);
      for (var i = 0; i < 3; i++) {
        for (var isRow in [true, false]) {
          final squares = box.squares.split((s) => (isRow ? s.row : s.col) % 3 == i && !candidates(s).isSingle);
          final boxLine = union(squares.match);
          final dLines = isRow ? dRows : dCols;
          final line = isRow ? rows[box.rowOffset + i] : cols[box.colOffset + i];
          for (var d = 1; d <= 9; d++) {
            if (boxLine.has(d)) {
              dLines[d - 1] += i + 2;
              var restOfLine = line.squares.where((s) => !squares.match.contains(s));
              if (union(squares.rest).has(d) && !union(restOfLine).has(d)) {
                for (var s in squares.rest) {
                  if (!eliminate(s, d)) return null;
                }
                return BoxLineIntersection(
                    'Box/Line reduction $d between $box and ${isRow ? 'Row' : 'Col'} ${i + 1 + (isRow ? box.rowOffset : box.colOffset)}');
              }
            }
          }
        }
      }
      for (var d = 1; d <= 9; d++) {
        for (var isRow in [true, false]) {
          final lines = isRow ? rows : cols;
          final dLines = isRow ? dRows : dCols;
          final offset = isRow ? box.rowOffset : box.colOffset;
          final index = dLines[d - 1] - 2;

          // If d is only in one row/col of the box it's a pointing pair
          if ([2, 3, 4].contains(dLines[d - 1])) {
            var rest = lines[index + offset].squares.where((s) => !s.units.contains(box));
            if (union(rest).has(d)) {
              for (var s in rest) {
                if (!eliminate(s, d)) return null;
              }
              return PointingPair(
                  'Pointing pair $d between $box and ${isRow ? 'Row' : 'Col'} ${index + 1 + (isRow ? box.rowOffset : box.colOffset)}');
            }
          }
        }
      }
    }

    return None();
  }
}

class PointingPair extends Technique {
  PointingPair(String message) : super(message, 100);
}

class BoxLineIntersection extends Technique {
  BoxLineIntersection(String message) : super(message, 100);
}
