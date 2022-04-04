import 'package:collection/collection.dart';

import '../candidates.dart';
import 'technique.dart';
import '../solver.dart';
import '../units.dart';

class ColorNode {
  /// A map of digits that have been visited for this square to the depth in the tree
  final digits = <int, int>{};

  ColorNode({required int depth, required int digit}) {
    digits[digit] = depth;
  }

  bool isGreen(int d) => digits.containsKey(d) ? digits[d]! % 2 == 0 : false;
  bool isRed(int d) => digits.containsKey(d) ? digits[d]! % 2 == 1 : false;
}

typedef Graph = Map<Square, ColorNode>;

extension SinglesChainExtension on Solution {
  Technique? medusa() {
    final result = singlesChain(true);
    if (result is Technique && result is! None) return Medusa('3D Medusa ' + result.message);

    return result;
  }

  Technique? singlesChain([bool is3d = false]) {
    for (var d = 1; d <= 9; d++) {
      // All squares with a strong link
      var conjugates = <Square>[];

      for (var unit in units) {
        final dInUnit = unit.squares.where((s) => candidates(s).has(d));
        // Is a conjugate pair
        if (dInUnit.length == 2) {
          // we only need 1 of the pair to start each graph build from, as the other
          // gets included regardless
          conjugates.add(dInUnit.first);
        }
      }

      for (var s in conjugates) {
        Graph nodes = {};
        if (nodes.containsKey(s)) continue;
        var rep = _buildGraph(nodes: nodes, current: s, d: d, depth: 0, is3d: is3d);
        if (nodes.length < 3) continue;

        // Rule 1
        // check for more than one of same color in cell
        if (is3d) {
          for (var s in nodes.keys) {
            var node = nodes[s]!;
            var squareGreens = 0, squareReds = 0;
            var coloredCandidates = Candidates(0);
            for (var d in node.digits.keys) {
              coloredCandidates = coloredCandidates.add(d);
              if (node.isGreen(d)) {
                squareGreens++;
                if (squareGreens > 1) {
                  if (!_removeColor(nodes, true)) return null;
                  // Rule 1
                  return Medusa('Rule 1\n$s has two green candidates ${node.digits}');
                }
              } else {
                squareReds++;
                if (squareReds > 1) {
                  if (!_removeColor(nodes, false)) return null;
                  // Rule 1
                  return Medusa('Rule 1\n$s has two red candidates ${node.digits}');
                }
              }
            }
            var uncolored = candidates(s).each().where((c) => !node.digits.containsKey(c));
            if (uncolored.isNotEmpty) {
              if (squareReds > 0 && squareGreens > 0) {
                for (var d in uncolored) {
                  if (!eliminate(s, d)) return null;
                  // Rule 3
                  return Medusa('Rule 3\n$s sees two colors in same cell: ${node.digits}');
                }
              }
              // The fact we're looking at only nodes means there is a colored candidate
              // So here we know there's either a red or green
              var message = '';
              for (var d in uncolored) {
                // Find peers that have a d with the opposite color of the colored candidate in this cell
                var other = s.peers.firstWhereOrNull(
                    (p) => nodes.containsKey(p) && (squareGreens > 0 ? nodes[p]!.isRed(d) : nodes[p]!.isGreen(d)));
                if (other != null) {
                  if (!eliminate(s, d)) return null;
                  message +=
                      'Uncolored $d in $s sees ${squareGreens > 0 ? 'green' : 'red'} in cell and ${squareGreens > 0 ? 'red' : 'green'} in $other\n';
                }
              }
              if (message.isNotEmpty) {
                print(rep);
                return Medusa('Rule 5\n$message');
              }
            }
          }

          for (var s in squares) {
            final c = candidates(s);
            if (nodes.containsKey(s) || c.isSingle) continue;
            for (var isGreen in [true, false]) {
              var seesAll = true;
              for (var d in c.each()) {
                if (!s.peers
                    .any((p) => nodes.containsKey(p) && (isGreen ? nodes[p]!.isGreen(d) : nodes[p]!.isRed(d)))) {
                  seesAll = false;
                  break;
                }
              }
              if (seesAll) {
                print(rep);
                if (!_removeColor(nodes, isGreen)) return null;
                // Rule 6
                return SinglesChain(
                    'Rule 6\nUncolored $s sees ${isGreen ? 'green' : 'red'} for all candidates in ${nodes.keys}');
              }
            }
          }
        }

        for (var d = 1; d <= 9; d++) {
          for (var unit in units) {
            var greenCount = 0;
            var redCount = 0;

            for (var s in nodes.keys) {
              var node = nodes[s]!;
              if (!s.units.contains(unit) || !node.digits.containsKey(d)) continue;
              if (node.isGreen(d) == true) {
                greenCount++;
              } else if (node.isRed(d) == true) {
                redCount++;
              }
            }

            if (greenCount > 1) {
              print(rep);
              if (!_removeColor(nodes, true)) return null;
              // Rule 2
              return SinglesChain('Rule 2\nGreen $d appears twice in $unit with ${nodes.keys}');
            }
            if (redCount > 1) {
              print(rep);
              if (!_removeColor(nodes, false)) return null;
              // Rule 2
              return SinglesChain('Rule 2\nRed $d appears twice in $unit with ${nodes.keys}');
            }
          }

          var seesBoth = squares.where((s) {
            // uncolored as part of this group chain
            if (!candidates(s).has(d) || nodes.containsKey(s)) return false;

            var greens = s.peers.where((s) => nodes.containsKey(s) && nodes[s]!.isGreen(d));
            var reds = s.peers.where((s) => nodes.containsKey(s) && nodes[s]!.isRed(d));

            // If it sees a green and red that share the same digit
            return union(greens).hasAny(union(reds));
          }).toList();

          if (seesBoth.isNotEmpty) {
            print(rep);
            for (var s in seesBoth) {
              if (!eliminate(s, d)) return null;
            }
            // Rule 4
            return SinglesChain('Rule 4\nUncolored $d in $seesBoth sees red and green in ${nodes.keys}');
          }
        }
      }
    }

    return None();
  }

  String _buildGraph({
    required Graph nodes,
    required Square current,
    required int d,
    bool is3d = false,
    int depth = 0,
    String path = '',
  }) {
    final visited = nodes.containsKey(current);
    // If it was already visited (for this d), move on.
    if (visited) {
      if (nodes[current]!.digits.containsKey(d)) return '';

      nodes[current]!.digits[d] = depth;
    } else {
      nodes[current] = ColorNode(
        digit: d,
        depth: depth,
      );
    }

    final otherCandidates = candidates(current).remove(d);
    final biValue = otherCandidates.isSingle ? otherCandidates.digit : null;

    var pairs = <Square>[];
    for (var unit in current.units) {
      var pair = unit.squares.where((s) => candidates(s).has(d) && s != current);
      if (pair.length == 1) pairs.add(pair.first);
    }

    var subpath = '';
    for (var pair in pairs) {
      subpath += _buildGraph(nodes: nodes, current: pair, d: d, depth: depth + 1, path: path, is3d: is3d);
    }
    // If 3D Medusa we can branch onto other candidates in bi-value cells
    if (is3d && biValue != null) {
      subpath +=
          '>' + _buildGraph(nodes: nodes, current: current, d: biValue, depth: depth + 1, path: path, is3d: is3d);
    }

    return '${nodes[current]!.isGreen(d) ? '+' : '-'}$d[$current${subpath == '' ? '' : ' {$subpath}'}]';
  }

  bool _removeColor(Graph nodes, bool removeGreens) {
    for (var s in nodes.keys) {
      var node = nodes[s]!;
      for (var d in node.digits.keys) {
        if (!(node.isGreen(d) ^ removeGreens)) {
          if (!eliminate(s, d)) return false;
        }
      }
    }
    return true;
  }
}

class SinglesChain extends Technique {
  SinglesChain(String message) : super(message, 100);
}

class Medusa extends Technique {
  Medusa(String message) : super(message, 100);
}
