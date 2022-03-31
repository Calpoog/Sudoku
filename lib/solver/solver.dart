import 'dart:math';

import 'package:collection/collection.dart';

import 'techniques/avoidable_rectangle.dart';
import 'techniques/technique.dart';
import 'candidates.dart';
import 'techniques/unique_rectangle.dart';
import 'techniques/x_cycle.dart';
import 'techniques/x_fish.dart';
import 'techniques/y_wings.dart';
import 'techniques/singles_chain.dart';
import 'techniques/box_intersection.dart';
import 'techniques/subsets.dart';
import 'units.dart';

final digitMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0};
final allDigits = int.parse('111111111', radix: 2);
final digitsBitmask = Map.fromEntries(List.generate(9, (i) => MapEntry(i + 1, 1 << 8 - i)));
final bitmaskDigits = Map.fromEntries(List.generate(9, (i) => MapEntry(1 << 8 - i, i + 1)));
final pairs = [
  for (var i = 9; i > 0; i--)
    for (var j = i - 1; j > 0; j--) Candidates(digitsBitmask[i]! | digitsBitmask[j]!)
];
final triplets = [
  for (var i = 9; i > 0; i--)
    for (var j = i - 1; j > 0; j--)
      for (var k = j - 1; k > 0; k--) Candidates(digitsBitmask[i]! | digitsBitmask[j]! | digitsBitmask[k]!)
];
final combos = [...pairs, ...triplets];

List<List<T>> combinations<T>(List<T> list, int size, [List<T>? previous]) {
  previous ??= [];
  if (previous.length == size) return List.of([previous]);
  final List<List<T>> combos = [];
  for (var i = 0; i < list.length; i++) {
    final copy = List<T>.from(previous);
    copy.add(list[i]);
    combos.addAll(combinations(list.sublist(i + 1), size, copy));
  }
  return combos;
}

class ListSplit<T> {
  final Iterable<T> match;
  final Iterable<T> rest;

  ListSplit(this.match, this.rest);
}

extension SplittableList<T> on Iterable<T> {
  ListSplit<T> split(bool Function(T) where) {
    final List<T> match = [];
    final List<T> rest = [];
    for (var item in this) {
      if (where(item)) {
        match.add(item);
      } else {
        rest.add(item);
      }
    }
    return ListSplit(match, rest);
  }
}

class Solution {
  final List<Row> rows = List.generate(9, (index) => Row(index));
  final List<Column> cols = List.generate(9, (index) => Column(index));
  final List<Box> boxes = List.generate(9, (index) => Box(index));
  late final List<Unit> units = [];
  CandidateState _candidates = {};

  /// A map of [Square]s to int representing its candidates as a bitmask
  /// 100101011 = 1..4.6.89
  // final CandidateState candidates = {};
  late final List<Square> squares;

  Solution._internal(Iterable<int> clues) {
    squares = List.generate(81, (i) {
      final row = (i / 9).floor();
      final col = i % 9;
      final box = (row / 3).floor() * 3 + (col / 3).floor();
      final square = Square(
        row: row,
        col: col,
        box: box,
        index: i,
        isClue: clues.elementAt(i) > 0,
      );
      rows[row].squares.add(square);
      cols[col].squares.add(square);
      boxes[box].squares.add(square);
      square.units.addAll([rows[row], cols[col], boxes[box]]);
      _candidates[square] = Candidates(allDigits);
      return square;
    });

    units
      ..addAll(rows)
      ..addAll(cols)
      ..addAll(boxes);

    for (var square in squares) {
      square.peers
        ..addAll(
          square.units.fold<Set<Square>>(
            <Square>{},
            (peers, unit) {
              return peers..addAll(unit.squares);
            },
          ),
        )
        ..remove(square);
    }

    for (int i = 0; i < clues.length; i++) {
      if (clues.elementAt(i) > 0) {
        if (!assign(squares[i], clues.elementAt(i))) break;
      }
    }
  }

  factory Solution.fromString(String grid) {
    final g = grid.replaceAll('.', '0').replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => int.parse(d));
    return Solution._internal(g)..solve();
  }

  bool assign(Square s, int d) {
    final others = candidates(s).remove(d);
    for (var d2 in others.each()) {
      if (!eliminate(s, d2)) return false;
    }
    return true;
  }

  bool eliminate(Square s, int d) {
    var c = candidates(s);
    // Already removed
    if (!c.has(d)) return true;
    // print('Eliminate $d from $s');
    c = _candidates[s] = c.remove(d);
    // All candidates removed, a contradiction
    if (c.isEmpty) {
      print('Contradiction eliminating $d from $s');
      display();
      return false;
    }

    // Only one candidate remains, propagate its removal from peers
    // Naked singles
    if (c.isSingle) {
      // print('Single candidate $d in $s');
      for (var peer in s.peers) {
        if (!eliminate(peer, c.digit)) return false;
      }
    }

    // Check if the square's units now only have 1 place d can be put
    // Hidden singles
    for (final unit in s.units) {
      final dPlaces = unit.squares.where((s) => candidates(s).has(d));
      if (dPlaces.isEmpty) {
        print('Contradiction: $unit has no place for $d');
        display();
        return false;
      } else if (dPlaces.length == 1) {
        // print('Hidden single $d in $unit');
        if (!assign(dPlaces.first, d)) return false;
      }
    }

    return true;
  }

  Square squareAt(int col, int row) {
    return rows[row].squares[col];
  }

  Candidates union(Iterable<Square> squares) {
    return squares.fold<Candidates>(Candidates(0), (previous, s) => candidates(s).union(previous));
  }

  List<Square> seesSquares(List<bool> sees) {
    return squares.whereIndexed((i, s) => sees[i]).toList();
  }

  Candidates candidates(Square s) {
    return _candidates[s]!;
  }

  void display() {
    final width = 2 + (squares.map((s) => candidates(s).length)).reduce(max);
    final line = '\n' + List.filled(3, List.filled(width * 3, '-').join('')).join('+');
    var result = '';
    for (var s in squares) {
      final val = candidates(s).toString();
      final pad = (width - val.length) / 2;
      result += val.padLeft(val.length + pad.ceil()).padRight(width);
      if (s.col == 2 || s.col == 5) result += '|';
      if ((s.row == 2 || s.row == 5) && s.col == 8) result += line;
      if (s.col == 8) result += '\n';
    }
    print(result + '\n\n\n.');
  }

  bool isSolved() {
    return _candidates.values.every((c) => c.isSingle);
  }

  solve() {
    final stopwatch = Stopwatch()..start();
    final result = applyLogic();
    stopwatch.stop();
    if (result) {
      print('RESULT:');
    } else {
      print('Unsolvable');
    }
    display();
    print(stopwatch.elapsed);
  }

  bool applyLogic() {
    final List<Technique? Function()> logicOrder = [
      nakedSubset,
      hiddenSubset,
      pointingPairs,
      () => xWings(rows, cols),
      () => xWings(cols, rows),
      singlesChain,
      yWings,
      () => swordfish(rows, cols),
      () => swordfish(cols, rows),
      xyzWings,
      () => jellyfish(rows, cols),
      () => jellyfish(cols, rows),
      xCycles,
      uniqueRect,
    ];
    Technique? result = None();
    var round = 0;
    while (result != null && !isSolved()) {
      round++;
      print('Round $round of logic');
      display();

      for (var i = 0; i < logicOrder.length; i++) {
        result = logicOrder[i]();
        if (result is None) continue;
        if (result is Technique) {
          print(result.message);
          break;
        } else {
          // If it was null, or applied a technique, we break the for to restart logic order
          break;
        }
      }

      if (result is None) {
        print('all logic failed');
        return false;
      }
    }
    return true;
  }

  // CandidateState? search(CandidateState? candidates, [int n = 0]) {
  //   if (candidates == null) return null;
  //   if (isSolved(candidates)) return candidates;
  //   print('Search $n');

  //   // Pick the cell with the least remaining candidates and try out each
  //   final x = squares.where((s) => candidates(s).length > 1);

  //   final s = x.sorted((a, b) => candidates(a]!.length - candidates[b).length).first;

  //   for (var d in candidates(s).each()) {
  //     print('Trying $d for $s');
  //     var result = search(applyLogic(assign(copy(candidates), s, d)), n + 1);
  //     print('Up to $n');
  //     if (result != null) return result;
  //   }
  //   return null;
  // }

  CandidateState copy(CandidateState candidates) {
    return candidates.map((s, c) => MapEntry(s, Candidates(c.value)));
  }
}
