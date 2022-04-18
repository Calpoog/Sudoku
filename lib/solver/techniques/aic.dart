import '../solver.dart';
import '../units.dart';
import 'technique.dart';

typedef Nodes = Map<Square, Map<int, DigitNode>>;

class DigitNode {
  static Map<String, DigitNode> _nodes = {};

  final Square square;
  final int digit;
  var visited = false;
  var partial = false;

  final weak = <DigitNode>{};
  final strong = <DigitNode>{};

  DigitNode._internal({required this.square, required this.digit});

  factory DigitNode(Square square, int digit) {
    final key = '$square$digit';
    return _nodes[key] = _nodes[key] ?? DigitNode._internal(square: square, digit: digit);
  }

  static void clear() => _nodes = {};

  @override
  String toString() {
    return '$square[$digit]';
  }
}

class Cycle {
  final List<DigitNode> nodes;
  final List<bool> strengths;
  final int? discontinuityIndex;
  final bool? isStrongDiscontinuity;

  Cycle({
    required this.nodes,
    required this.strengths,
    this.discontinuityIndex,
    this.isStrongDiscontinuity,
  });

  @override
  String toString() {
    var result = '';
    var state = isStrongDiscontinuity ?? true;
    for (var i = 0; i <= nodes.length; i++) {
      final index = (i + (discontinuityIndex ?? 0)) % nodes.length;
      result += '${strengths[(index + 1) % nodes.length] ? '+' : '-'}${nodes[index].digit}[${nodes[index].square}]';
      state = !state;
    }
    return result;
  }
}

extension AlternatingInferenceChainExtension on Puzzle {
  Technique? aic() {
    DigitNode.clear();
    for (var s in squares) {
      final nodes = <DigitNode>[];
      final c = candidates(s);
      if (c.length < 2) continue;
      for (var d in c.each()) {
        final node = DigitNode(s, d);
        nodes.add(node);

        for (var unit in s.units) {
          final others = unit.squares.where((s2) => s != s2 && candidates(s2).has(d));
          if (others.length == 1) {
            // Strong links within the unit for this digit
            node.strong.add(DigitNode(others.first, d));
          } else if (others.length > 1) {
            // Weak links within the unit for this digit
            for (var other in others) {
              node.weak.add(DigitNode(other, d));
            }
          }
        }
      }
      // Bi-value cell candidates are strong linked to each other
      if (c.length == 2) {
        nodes.first.strong.add(nodes.last);
        nodes.last.strong.add(nodes.first);
      } else if (c.length > 1) {
        // 3+ candidates are weak linked to each other
        for (var n in nodes) {
          n.weak.addAll(nodes.where((n2) => n2 != n));
        }
      }
    }

    // display();
    // final result = _findCycle(node: DigitNode(squares[10], 7), path: [], strengths: []);
    // print(result);

    var nodes = DigitNode._nodes;

    for (var node in DigitNode._nodes.values.where((n) => n.strong.isNotEmpty)) {
      // if (node.visited) continue;
      print('starting from $node');
      final result = _findCycle(node: node, path: [], strengths: []);
      if (result != null) return result;
    }

    return None();
  }

  Technique? _rule1(Cycle cycle) {
    final messages = <String>[];
    for (var i = 0; i < cycle.nodes.length; i++) {
      final isWeak = !cycle.strengths[i];
      final current = cycle.nodes[i];
      final next = current == cycle.nodes.last ? cycle.nodes.first : cycle.nodes[i + 1];

      if (current.digit == next.digit && isWeak) {
        final d = next.digit;
        final affected = <Square>[];
        if (current.square.row == next.square.row) {
          affected.addAll(rows[current.square.row]
              .squares
              .where((s) => s != current.square && s != next.square && candidates(s).has(d)));
        }
        if (current.square.col == next.square.col) {
          affected.addAll(cols[current.square.col]
              .squares
              .where((s) => s != current.square && s != next.square && candidates(s).has(d)));
        }
        if (current.square.box == next.square.box) {
          affected.addAll(boxes[current.square.box]
              .squares
              .where((s) => s != current.square && s != next.square && candidates(s).has(d)));
        }
        if (affected.isNotEmpty) {
          for (var s in affected) {
            messages.add('Off-chain candidate $d taken off $s');
            if (!eliminate(s, d)) return null;
          }
        }
      }
    }

    if (messages.isNotEmpty) {
      return AlternatingInferenceChain('AIC, $cycle\n${messages.join('\n')}');
    }

    return null;
  }

  Technique? _rule2(Cycle cycle) {
    final node = cycle.nodes[cycle.discontinuityIndex!];
    if (candidates(node.square).length == 1) return null;
    if (!assign(node.square, node.digit)) return null;
    print(cycle.strengths);
    print(cycle.nodes);
    return AlternatingInferenceChain('AIC Rule 2, $cycle\nStrong discontinuity for ${node.digit} in ${node.square}');
  }

  Technique? _rule3(Cycle cycle) {
    final node = cycle.nodes[cycle.discontinuityIndex!];
    if (!eliminate(node.square, node.digit)) return null;
    return AlternatingInferenceChain('AIC Rule 3, $cycle\nWeak discontinuity for ${node.digit} in ${node.square}');
  }

  Technique? _findCycle({
    required DigitNode node,
    required List<DigitNode> path,
    required List<bool> strengths,
  }) {
    final lastNode = path.isEmpty ? null : path.last;

    var startIndex = path.indexOf(node);
    if (startIndex >= 0) {
      // print(path);
      // print('attempted cycle: ${path.sublist(startIndex)}');
      final cycle = _makeCycle(nodes: path.sublist(startIndex), strengths: strengths.sublist(startIndex));

      if (cycle != null) {
        Technique? result;

        if (cycle.discontinuityIndex == null) {
          result = _rule1(cycle);
          // print('SUCCESS rule 1: $result');
        } else {
          result = cycle.isStrongDiscontinuity == true ? _rule2(cycle) : _rule3(cycle);
          // print('SUCCESS rule 2/3: $result');
        }
        if (result != null) return result;
      }

      return null;
    }

    // if (node.visited) return null;

    var newPath = [...path, node];
    node.partial = true;

    // print(newPath);

    for (var strong in node.strong) {
      if (strong == lastNode) continue;
      final result = _findCycle(
        node: strong,
        path: newPath,
        strengths: [...strengths, true],
      );
      if (result != null) return result;
    }

    final length = path.length;
    // don't do 3 weaks in a row
    if (length > 2 && (strengths.last || strengths[length - 2])) {
      for (var weak in node.weak) {
        if (weak == lastNode) continue;
        final result = _findCycle(
          node: weak,
          path: newPath,
          strengths: [...strengths, false],
        );
        if (result != null) return result;
      }
    }

    node.visited = true;

    return null;
  }

  Cycle? _makeCycle({
    required List<DigitNode> nodes,
    required List<bool> strengths,
  }) {
    if (nodes.length < 4) return null;

    if (Set.from(nodes.map((n) => n.square)).length < 4) return null;

    // Start from a hard weak so we can establish a pattern
    var firstWeak = strengths.indexOf(false);
    if (firstWeak < 0) firstWeak = 0;

    int? discontinuityIndex;
    bool? isStrongDiscontinuity;

    for (var i = 0; i <= strengths.length; i++) {
      final index = (i + firstWeak) % strengths.length;
      final isStrong = strengths[index];
      // Is weak where it should be strong
      if (i % 2 == (discontinuityIndex == null ? 1 : 0) && !isStrong) {
        // Even cycles can't have discontinuities
        if (strengths.length % 2 == 0) {
          // print('discontinuity in even cycle');
          return null;
        }
        // was weak + weak
        if (!strengths[index - 1]) {
          // print('weak + weak @ ${nodes[index]}');
          if (discontinuityIndex != null) {
            // print('but there were two :(');
            return null;
          }
          discontinuityIndex = index;
        }
        // was previously strong, first discontinuity so means there was a strong + strong
        else {
          // print('strong + strong @ ${nodes[index - 1]}');
          if (discontinuityIndex != null) {
            // print('but there were two :(');
            return null;
          }
          discontinuityIndex = index - 1;
          isStrongDiscontinuity = true;
        }
      }
    }

    return Cycle(
      nodes: nodes,
      strengths: strengths,
      discontinuityIndex: discontinuityIndex,
      isStrongDiscontinuity: isStrongDiscontinuity,
    );
  }
}

class AlternatingInferenceChain extends Technique {
  AlternatingInferenceChain(String message) : super(message, 12000, 8000);
}
