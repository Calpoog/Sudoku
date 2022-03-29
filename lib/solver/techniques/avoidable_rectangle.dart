import '../solver.dart';
import '../units.dart';
import 'technique.dart';

extension AvoidableRectangleExtension on Solution {
  Technique? avoidableRect() {
    for (var d = 1; d <= 9; d++) {
      final ds = squares.where((s) => candidates(s).value == bitmaskDigits[d]);

      for (var s in ds) {
        if (s.isClue) continue;
        for (var diagonal in ds) {
          final isSameBoxRow = (s.box / 3).floor() == (diagonal.box / 3).floor();
          final isSameBoxCol = s.box % 3 == diagonal.box % 3;
          if (diagonal == s || diagonal.isClue || !(isSameBoxCol ^ isSameBoxRow)) continue;
          final vertical = squares[diagonal.row * 9 + s.col];
          final horizontal = squares[s.row * 9 + diagonal.col];
          if (vertical.isClue || horizontal.isClue) continue;

          final vc = candidates(vertical);
          final hc = candidates(horizontal);

          var found = false;
          if (vc.isSingle && hc.length > 1 && hc.hasAny(vc)) {
            if (!eliminate(horizontal, vc.digit)) return null;
            found = true;
          } else if (hc.isSingle && vc.length > 1 && vc.hasAny(vc)) {
            if (!eliminate(vertical, hc.digit)) return null;
            found = true;
          }
          if (found) return AvoidableRectangle('Avoidable rectangle for $d in $s, $horizontal, $diagonal, $vertical');
        }
      }
    }
    return None();
  }
}

class AvoidableRectangle extends Technique {
  AvoidableRectangle(String message) : super(message, 100);
}
