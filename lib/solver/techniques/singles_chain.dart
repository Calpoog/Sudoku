import 'technique.dart';
import '../solver.dart';
import '../units.dart';

class ColorNode {
  final pairs = <Square>{};
  var visited = false;
  var group = -1;
  var depth = -1;

  get isGreen => depth % 2 == 0;
}

typedef Graph = Map<Square, ColorNode>;

extension SinglesChainExtension on Solution {
  Technique? singlesChain() {
    for (var d = 1; d <= 9; d++) {
      Graph nodes = {};

      for (var unit in units) {
        final dInUnit = unit.squares.where((s) => candidates(s).has(d));
        // Is a conjugate pair
        if (dInUnit.length == 2) {
          nodes[dInUnit.first] = nodes[dInUnit.first] ?? ColorNode();
          nodes[dInUnit.first]!.pairs.add(dInUnit.last);
          nodes[dInUnit.last] = nodes[dInUnit.last] ?? ColorNode();
          nodes[dInUnit.last]!.pairs.add(dInUnit.first);
        }
      }

      var groupId = 0;
      for (var s in nodes.keys) {
        if (nodes[s]!.visited) continue;
        _buildGraph(nodes, s, groupId++);
      }

      for (var g = 0; g < groupId; g++) {
        var group = nodes.keys.where((s) => nodes[s]!.group == g);
        for (var unit in units) {
          var greenCount = 0;
          var redCount = 0;

          for (var s in nodes.keys) {
            var node = nodes[s]!;
            if (node.group != g || !s.units.contains(unit)) continue;
            if (node.isGreen) {
              greenCount++;
            } else {
              redCount++;
            }
          }

          if (greenCount > 1) {
            _removeColor(d, nodes, g, true);
            return SinglesChain('Green $d appears twice in $unit with $group');
          }
          if (redCount > 1) {
            _removeColor(d, nodes, g, false);
            return SinglesChain('Red $d appears twice in $unit with $group');
          }
        }

        var seesBoth = squares.where((s) {
          // uncolored as part of this group chain
          if (!candidates(s).has(d) || nodes.containsKey(s)) return false;

          var seesGreen = s.peers.any((s) => nodes.containsKey(s) && nodes[s]!.isGreen && nodes[s]!.group == g);
          var seesRed = s.peers.any((s) => nodes.containsKey(s) && !nodes[s]!.isGreen && nodes[s]!.group == g);

          return seesGreen && seesRed;
        }).toList();

        if (seesBoth.isNotEmpty) {
          for (var s in seesBoth) {
            if (!eliminate(s, d)) return null;
          }
          return SinglesChain('Uncolored $d in $seesBoth sees red and green in $group');
        }
      }
    }

    return None();
  }

  void _buildGraph(Graph nodes, Square current, int groupId, [int depth = 0]) {
    final node = nodes[current]!;
    if (node.visited) return;

    node.visited = true;
    node.depth = depth;
    node.group = groupId;

    for (var pair in node.pairs) {
      _buildGraph(nodes, pair, groupId, depth + 1);
    }
  }

  bool _removeColor(int d, Graph nodes, int groupId, bool removeGreens) {
    for (var s in nodes.keys) {
      var node = nodes[s]!;
      if (node.group == groupId && !(node.isGreen ^ removeGreens)) {
        if (!eliminate(s, d)) return false;
      }
    }
    return true;
  }
}

class SinglesChain extends Technique {
  SinglesChain(String message) : super(message, 100);
}
