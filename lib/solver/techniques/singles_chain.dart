import 'technique.dart';
import '../candidates.dart';
import '../solver.dart';
import '../units.dart';

enum CandidateColor { uncolored, green, red }

class ColoredCandidate {
  final Square square;
  final pairs = <ColoredCandidate>{};
  int group = 0;
  CandidateColor? color;

  ColoredCandidate(this.square);

  get visited => color != null;

  @override
  String toString() {
    return square.toString() + '($group:${color.toString().replaceFirst('CandidateColor.', '')})';
  }
}

extension SinglesChainExtension on Solution {
  Technique? singlesChain() {
    for (var d = 1; d <= 9; d++) {
      final colors = <ColoredCandidate>{};

      for (var unit in units) {
        final dInUnit = unit.squares.where((s) => candidates(s).has(d));
        // Is a conjugate pair
        if (dInUnit.length == 2) {
          var start =
              colors.firstWhere((c) => c.square == dInUnit.first, orElse: () => ColoredCandidate(dInUnit.first));
          var end = colors.firstWhere((c) => c.square == dInUnit.last, orElse: () => ColoredCandidate(dInUnit.last));
          colors.add(start..pairs.add(end));
          colors.add(end..pairs.add(start));
        }
      }

      var groupId = 0;
      for (var colored in colors) {
        if (_doColoring(colored, groupId) > 0) groupId++;
      }
      colors.retainWhere((c) => c.color != CandidateColor.uncolored);

      for (var g = 0; g < groupId; g++) {
        final group = colors.where((c) => c.group == g);
        Map<Unit, bool> unitReds = {};
        Map<Unit, bool> unitGreens = {};
        // A map of uncolored squares and true: sees green, false: sees red, null: sees both
        Map<Square, bool?> uncoloredSees = {};
        for (var c in group) {
          for (var unit in c.square.units) {
            final isGreen = c.color == CandidateColor.green;
            if (isGreen) {
              if (unitGreens[unit] == true) {
                if (!_removeColor(d, group, CandidateColor.green)) return null;
                return SinglesChain('Green $d appears twice in $unit with chain $group');
              }
              if (unitReds[unit] == true) {
                final result = _removeUncolored(d, group, unit);
                if (result is! None) return result;
              }
              unitGreens[unit] = true;
            } else {
              if (unitReds[unit] == true) {
                if (!_removeColor(d, group, CandidateColor.red)) return null;
                return SinglesChain('Red $d appears twice in $unit with chain $group');
              }
              if (unitGreens[unit] == true) {
                final result = _removeUncolored(d, group, unit);
                if (result is! None) return result;
              }
              unitReds[unit] = true;
            }

            // If any uncolored square in this unit "sees" both colors, it gets eliminated
            for (var s in unit.squares) {
              if (_isUncolored(d, group, s)) {
                if (!uncoloredSees.containsKey(s)) {
                  uncoloredSees[s] = isGreen ? true : false;
                }
                // Sees both
                else if ((uncoloredSees[s] == false && isGreen) || (uncoloredSees[s] == true && !isGreen)) {
                  if (!eliminate(s, d)) return null;
                  return SinglesChain('Uncolored $d in $s sees red and green in chain $group');
                }
              }
            }
          }
        }
      }
    }

    return None();
  }

  bool _isUncolored(int d, Iterable<ColoredCandidate> chain, Square s) {
    return candidates(s).has(d) && !chain.any((c) => c.square == s);
  }

  Iterable<Square> _getUncolored(int d, Iterable<ColoredCandidate> chain, Iterable<Square> squares) {
    return squares.where((s) => _isUncolored(d, chain, s));
  }

  bool _removeColor(int d, Iterable<ColoredCandidate> chain, CandidateColor color) {
    for (var c in chain) {
      if (!eliminate(c.square, d)) return false;
    }
    return true;
  }

  Technique? _removeUncolored(int d, Iterable<ColoredCandidate> chain, Unit unit) {
    var uncolored = _getUncolored(d, chain, unit.squares);
    if (uncolored.isNotEmpty) {
      for (var s in uncolored) {
        if (!eliminate(s, d)) return null;
      }
      return SinglesChain('Opposite colors for $d in $unit, with chain $chain');
    }
    return None();
  }

  // Traverses the chain and returns how far it got (because the chains have to be length > 2)
  int _doColoring(ColoredCandidate start, int group, [int depth = 0]) {
    if (start.visited) return 0;

    start.color = CandidateColor.uncolored;
    start.group = group;

    var length = depth;
    // A list of branches that were of length 1, that get revisited to be colored
    // if this node ends up as part of a valid length chain
    var shortBranches = <ColoredCandidate>[];
    for (var pair in start.pairs) {
      var branchLength = _doColoring(pair, group, depth + 1);
      length += branchLength;
      if (branchLength == 1) shortBranches.add(pair);
    }

    if (length >= 2) {
      for (var c in shortBranches) {
        c.color = depth % 2 == 0 ? CandidateColor.red : CandidateColor.green;
      }
      start.color = depth % 2 == 0 ? CandidateColor.green : CandidateColor.red;
    }

    return length;
  }
}

class SinglesChain extends Technique {
  SinglesChain(String message) : super(message, 100);
}
