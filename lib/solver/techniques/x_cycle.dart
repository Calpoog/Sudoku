import '../solver.dart';
import '../units.dart';
import 'technique.dart';

class CycleNode {
  final int digit;
  final Square square;
  bool visited = false;
  final Set<Square> weak = {};
  final Set<Square> strong = {};

  CycleNode({required this.digit, required this.square});
}

class Cycle {
  final List<Square> squares;
  final List<bool> strengths;
  int? discontinuityIndex;
  bool isStrongDiscontinuity = false;

  Cycle({required this.squares, required this.strengths});

  @override
  String toString() {
    var state = true;
    var result = '';
    for (var i = 0; i < squares.length; i++) {
      final index = (i + (discontinuityIndex ?? 0)) % squares.length;
      result += '${state ? '+' : '-'}[${squares[index]}]';
      state = !state;
    }
    return result;
  }
}

extension XCycleExtension on Solution {
  Technique? xCycles() {
    for (var d = 1; d <= 9; d++) {
      final nodes = <Square, CycleNode>{};
      for (var unit in units) {
        final dInUnit = unit.squares.where((s) => candidates(s).has(d));
        if (dInUnit.length == 2) {
          final s1 = dInUnit.first;
          final s2 = dInUnit.last;
          nodes[s1] = nodes[s1] ?? CycleNode(digit: d, square: s1);
          nodes[s1]!.strong.add(s2);
          nodes[s2] = nodes[s2] ?? CycleNode(digit: d, square: s2);
          nodes[s2]!.strong.add(s1);
        }
      }
      // Add any weak links between strong-linked pairs
      for (var s in nodes.keys) {
        nodes[s]!.weak.addAll(nodes.keys.where((s2) => s.peers.contains(s2) && !nodes[s]!.strong.contains(s2)));
      }
      // Add any weak links to non-strong-linked pairs
      for (var s in List.from(nodes.keys)) {
        final sees = s.peers.where((p) => candidates(p).has(d) && !nodes[s]!.strong.contains(p));
        nodes[s]!.weak.addAll(sees);
        for (var s2 in sees) {
          nodes[s2] = nodes[s2] ?? CycleNode(digit: d, square: s);
          nodes[s2]!.weak.add(s);
        }
      }

      // print('graphed $d');

      for (var s in nodes.keys) {
        // if (nodes[s]!.visited) continue;
        // print('starting from $s');
        final cycle = findCycle(nodes: nodes, path: [], strengths: [], s: s);
        if (cycle != null) {
          // print('found cycle');
          var result;
          if (cycle.discontinuityIndex == null) {
            result = rule1(cycle, d);
          } else {
            result = cycle.isStrongDiscontinuity ? rule2(cycle, d) : rule3(cycle, d);
          }
          if (result != null) return result;
        }
      }
    }
    return None();
  }

  Technique? rule1(Cycle cycle, int d) {
    final affected = <Square>[];
    for (var i = 0; i < cycle.squares.length; i++) {
      final prev = i == 0 ? cycle.squares.last : cycle.squares[i - 1];
      final current = cycle.squares[i];
      if (current.row == prev.row) {
        affected.addAll(rows[current.row].squares.where((s) => s != current && s != prev && candidates(s).has(d)));
      }
      if (current.col == prev.col) {
        affected.addAll(cols[current.col].squares.where((s) => s != current && s != prev && candidates(s).has(d)));
      }
      if (current.box == prev.box) {
        affected.addAll(boxes[current.box].squares.where((s) => s != current && s != prev && candidates(s).has(d)));
      }
    }
    if (affected.isNotEmpty) {
      for (var s in affected) {
        if (!eliminate(s, d)) return null;
      }
      display();
      return XCycle('XCycle Rule 1 for $d, $cycle');
    }

    return null;
  }

  Technique? rule2(Cycle cycle, int d) {
    if (!assign(cycle.squares[cycle.discontinuityIndex!], d)) return null;
    return XCycle('XCycle Rule 2 for $d, $cycle');
  }

  Technique? rule3(Cycle cycle, int d) {
    if (!eliminate(cycle.squares[cycle.discontinuityIndex!], d)) return null;
    return XCycle('XCycle Rule 3 for $d, $cycle');
  }

  Cycle? findCycle({
    required Map<Square, CycleNode> nodes,
    required List<Square> path,
    required List<bool> strengths,
    required Square s,
  }) {
    final startIndex = path.indexOf(s);
    if (startIndex >= 0) {
      // print('found cycle');
      final cycle = Cycle(squares: path.sublist(startIndex), strengths: strengths.sublist(startIndex));
      if (isValidCycle(nodes: nodes, cycle: cycle)) return cycle;
      return null;
    }

    var newPath = [...path, s];
    final node = nodes[s]!;
    node.visited = true;
    // seen shared squares between the first and last
    // final shared = path.isEmpty ? <Square>[] : seesSquares(s.seesUnion(path.first));

    for (var which in [node.strong, node.weak]) {
      final isStrong = which == node.strong;
      var newStrengths = [...strengths, isStrong];
      for (var next in which) {
        if (path.isNotEmpty && next == path.last) continue;
        final result = findCycle(
          nodes: nodes,
          path: newPath,
          strengths: newStrengths,
          s: next,
        );
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  bool isValidCycle({required Map<Square, CycleNode> nodes, required Cycle cycle}) {
    if (cycle.squares.length < 4) return false;

    final strengths = cycle.strengths;

    // Start from a hard weak so we can establish a pattern
    var firstWeak = strengths.indexOf(false);
    if (firstWeak < 0) firstWeak = 0;

    for (var i = 0; i < strengths.length; i++) {
      final index = (i + firstWeak) % strengths.length;
      final isStrong = strengths[index];
      // Is weak where it should be strong
      if (i % 2 == (cycle.discontinuityIndex == null ? 1 : 0) && !isStrong) {
        // Even cycles can't have discontinuities
        if (strengths.length % 2 == 0) return false;
        // was weak + weak
        if (!strengths[index - 1]) {
          if (cycle.discontinuityIndex != null) return false;
          cycle.discontinuityIndex = index;
          // print('weak discontinuity at ${cycle.squares[index]}');
        }
        // was previously strong, first discontinuity so means there was a strong + strong
        else {
          if (cycle.discontinuityIndex != null) return false;
          cycle
            ..discontinuityIndex = index - 1
            ..isStrongDiscontinuity = true;
          // print('strong discontinuity at ${cycle.squares[index - 1]}');
        }
      }
    }

    return true;
  }
}

class XCycle extends Technique {
  XCycle(String message) : super(message, 100);
}
