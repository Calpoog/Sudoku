import '../candidates.dart';
import '../solver.dart';
import '../units.dart';
import 'technique.dart';

extension ForcingChainExtension on Puzzle {
  Technique? forcingChain() {
    // squares ordered by remaining candidates (>= 2)
    final ordered = squares.where((s) => candidates(s).length > 2).toList()
      ..sort(
        (a, b) => candidates(a).length - candidates(b).length,
      );

    for (var o in ordered) {
      for (var d in candidates(o).each()) {
        final dOn = copy();
        if (!assign(o, d, dOn)) continue;
        final dOff = copy();
        if (!assign(o, d, dOff)) continue;

        for (var s in squares) {
          final c = candidates(s);
          final List<Square> affected = [];
          if (!c.isSingle) {
            if (dOn[s]!.isSingle && dOff[s]!.isSingle) {
              if (dOn[s]!.equals(dOff[s]!)) {
                // Type 1
                if (!assign(s, dOn[s]!.digit)) return null;
              } else {
                // Type 3
                final others = Candidates().removeAll(dOn[s]!).removeAll(dOff[s]!);
                for (var r in others.each()) {
                  if (!eliminate(s, r)) return null;
                }
              }
              affected.add(s);
            } else {
              // If a candidate is removed, unique with the original shows which were eliminated
              // intersect those of the on/off states to get which were removed in both cases
              var removed = c.unique(dOn[s]!).intersection(c.unique(dOff[s]!));
              if (removed.length > 1) {
                for (var r in removed.each()) {
                  if (!eliminate(s, r)) return null;
                }
                affected.add(s);
              }
            }
          }

          if (affected.isNotEmpty) {
            return DigitForcingChain('Digit forcing chain, $affected');
          }
        }
      }
    }

    return None();
  }
}

class DigitForcingChain extends Technique {
  DigitForcingChain(String message) : super(message, 14000, 8000);
}
