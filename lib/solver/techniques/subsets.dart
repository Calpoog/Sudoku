import 'technique.dart';
import '../candidates.dart';
import '../solver.dart';
import '../units.dart';

extension SubsetExtension on Puzzle {
  Technique? nakedSubset(List<Candidates> combos) {
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
            return _nakedSubset(combo: combo, unit: unit);
          }
        }
      }
    }

    return None();
  }

  Technique? hiddenSubset(List<Candidates> combos) {
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
          return _hiddenSubset(combo: combo, unit: unit);
        }
      }
    }

    return None();
  }
}

Technique _nakedSubset({required Candidates combo, required Unit unit}) {
  switch (combo.length) {
    case 2:
      return NakedPair(combo: combo, unit: unit);
    case 3:
      return NakedTriple(combo: combo, unit: unit);
    case 4:
      return NakedQuad(combo: combo, unit: unit);
  }
  return None();
}

Technique _hiddenSubset({required Candidates combo, required Unit unit}) {
  switch (combo.length) {
    case 2:
      return HiddenPair(combo: combo, unit: unit);
    case 3:
      return HiddenTriple(combo: combo, unit: unit);
    case 4:
      return HiddenQuad(combo: combo, unit: unit);
  }
  return None();
}

class Subset extends Technique {
  Subset({
    required String type,
    required Candidates combo,
    required Unit unit,
    required int difficulty,
    required int reuse,
  }) : super('$type $combo found in $unit', difficulty, reuse);
}

class NakedPair extends Subset {
  NakedPair({required Candidates combo, required Unit unit})
      : super(type: 'Naked Pair', combo: combo, unit: unit, difficulty: 750, reuse: 500);
}

class HiddenPair extends Subset {
  HiddenPair({required Candidates combo, required Unit unit})
      : super(type: 'Hidden Pair', combo: combo, unit: unit, difficulty: 1500, reuse: 1200);
}

class NakedTriple extends Subset {
  NakedTriple({required Candidates combo, required Unit unit})
      : super(type: 'Naked Triple', combo: combo, unit: unit, difficulty: 2000, reuse: 1400);
}

class HiddenTriple extends Subset {
  HiddenTriple({required Candidates combo, required Unit unit})
      : super(type: 'Hidden Triple', combo: combo, unit: unit, difficulty: 2400, reuse: 1600);
}

class NakedQuad extends Subset {
  NakedQuad({required Candidates combo, required Unit unit})
      : super(type: 'Naked Quad', combo: combo, unit: unit, difficulty: 5000, reuse: 4000);
}

class HiddenQuad extends Subset {
  HiddenQuad({required Candidates combo, required Unit unit})
      : super(type: 'Hidden Quad', combo: combo, unit: unit, difficulty: 7000, reuse: 5000);
}
