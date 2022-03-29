import 'technique.dart';
import '../candidates.dart';
import '../solver.dart';
import '../units.dart';

extension SubsetExtension on Solution {
  Technique? nakedSubset() {
    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        for (var s in unit.squares) {
          if (!candidates(s).isSingle && candidates(s).hasOnlyAny(combo)) matches.add(s);
        }

        if (matches.length == combo.length) {
          var affected = unit.squares.where((s) => !matches.contains(s));
          if (union(affected).hasAny(combo)) {
            for (var s in affected) {
              for (var d in combo.each()) {
                if (!eliminate(s, d)) return null;
              }
            }
            return NakedSubset('Naked subset $combo found in $unit');
          }
        }
      }
    }

    return None();
  }

  Technique? hiddenSubset() {
    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        // This needs to end up containing the combo. e.g. we union up the subset
        // matches, so we make sure it doesn't just find 1,1,1 as a "triplet". It
        // also tells us when its length > combo.length that there were other
        // candidates present that prove it was "hidden."
        var foundCandidates = Candidates(0);

        for (var s in unit.squares) {
          if (!candidates(s).isSingle && candidates(s).hasAny(combo)) {
            matches.add(s);
            foundCandidates = foundCandidates.union(candidates(s));
          }
        }

        if (matches.length == combo.length && foundCandidates.hasAll(combo) && !foundCandidates.equals(combo)) {
          for (var s in matches) {
            for (var d = 1; d <= 9; d++) {
              if (!combo.has(d)) {
                if (!eliminate(s, d)) return null;
              }
            }
          }
          return HiddenSubset('Hidden subset $combo found in $unit');
        }
      }
    }

    return None();
  }
}

class NakedSubset extends Technique {
  NakedSubset(String message) : super(message, 100);
}

class HiddenSubset extends Technique {
  HiddenSubset(String message) : super(message, 100);
}
