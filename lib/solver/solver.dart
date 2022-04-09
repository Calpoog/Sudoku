import 'dart:math';

import 'package:collection/collection.dart';

import 'techniques/forcing_chain.dart';
import 'techniques/technique.dart';
import 'candidates.dart';
import 'techniques/unique_rectangle.dart';
import 'techniques/x_cycle.dart';
import 'techniques/x_fish.dart';
import 'techniques/y_wings.dart';
import 'techniques/singles_chain.dart';
import 'techniques/subsets.dart';
import 'units.dart';

final digitMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0};
final allDigits = int.parse('111111111', radix: 2);
final digitsBitmask = Map.fromEntries(List.generate(9, (i) => MapEntry(i + 1, 1 << 8 - i)));
final bitmaskDigits = Map.fromEntries(List.generate(9, (i) => MapEntry(1 << 8 - i, i + 1)));
final singles = [1, 2, 3, 4, 5, 6, 7, 8, 9];
final fullCandidates = Candidates();
final pairs =
    combinations(singles, 2).map((group) => group.fold<Candidates>(Candidates(0), (prev, d) => prev.add(d))).toList();
final triplets =
    combinations(singles, 3).map((group) => group.fold<Candidates>(Candidates(0), (prev, d) => prev.add(d))).toList();
final quads =
    combinations(singles, 4).map((group) => group.fold<Candidates>(Candidates(0), (prev, d) => prev.add(d))).toList();

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

final List<Row> rows = List.generate(9, (index) => Row(index));
final List<Column> cols = List.generate(9, (index) => Column(index));
final List<Box> boxes = List.generate(9, (index) => Box(index));
final List<Unit> units = [...rows, ...cols, ...boxes];
final _squares = List.generate(81, (i) {
  final row = (i / 9).floor();
  final col = i % 9;
  final box = (row / 3).floor() * 3 + (col / 3).floor();
  final square = Square(
    row: row,
    col: col,
    box: box,
    index: i,
    // isClue: clues.elementAt(i) > 0,
  );
  rows[row].squares.add(square);
  cols[col].squares.add(square);
  boxes[box].squares.add(square);
  square.units.addAll([rows[row], cols[col], boxes[box]]);
  return square;
});
final squares = _squares.map((s) {
  s.peers
    ..addAll(
      s.units.fold<Set<Square>>(
        <Square>{},
        (peers, unit) {
          return peers..addAll(unit.squares);
        },
      ),
    )
    ..remove(s);
  return s;
}).toList();

class Puzzle {
  final rand = Random();
  List<Technique> techniques = [];
  CandidateState _candidates = {};

  Puzzle.fromClues(Iterable<int> clues) {
    _setup(clues);
  }

  Puzzle.fromString(String grid) {
    final g = grid.replaceAll('.', '0').replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => int.parse(d));
    _setup(g);
  }

  Puzzle.solved() {
    _create();
  }

  Puzzle.withDifficulty({min = 0, max = 1000000}) {
    while (true) {
      print('STARTING OVER');
      final solved = Puzzle.solved();
      final clues = squares.map((s) => solved.candidates(s).digit).toList();
      var difficulty = 0;
      var removed = 0;

      while (removed < 40) {
        var i = rand.nextInt(81);
        if (clues[i] > 0) {
          clues[i] = 0;
          removed++;
        }
      }

      for (var tries = 0; tries < 1000; tries++) {
        var i = rand.nextInt(81);
        final c = clues[i];
        if (c == 0) continue;
        clues[i] = 0;
        print('Removing $c from ${squares[i]}');
        print(clues);

        // In order to be well formed, there must be 8 unique digits in the givens
        if (Set.from(clues).length < 8) {
          print('Oops, not well-formed');
          clues[i] = c;
          continue;
        }

        techniques = [];
        _setup(clues);
        print('After Setup');
        display();

        final count = countSolutions();

        // If this causes multiple solutions, try again
        if (count > 1) {
          clues[i] = c;
          print('Multiple solutions');
          break;
        }

        final result = solve();

        // If it was logically solved, the difficulty may or may not kill the loop
        // If it doesn't it will continue to remove squares
        if (result) {
          final used = <Type>{};
          difficulty = techniques.fold(0, (prev, t) {
            return (used.add(t.runtimeType) ? t.difficulty : t.reuse) + prev;
          });
          final numClues = clues.where((c) => c > 0).length;
          final t = techniques.where((t) => t is! HiddenSingle && t is! NakedSingle);
          print(t);
          print(t.map((t) => t.message).join('\n'));
          print('Solution with $difficulty difficulty and $numClues clues');
          display();
          print(clues.join(''));
          if (difficulty >= min && difficulty <= max && isSolved()) return;
        } else {
          clues[i] = c;
          print('No solution with logic');
        }
      }
    }
  }

  void _create() {
    _setup(List.filled(81, 0));

    for (var b = 0; b <= 8; b += 4) {
      var box = boxes[b];
      for (var s in box.squares) {
        var c = candidates(s).each();
        if (c.length > 1) {
          var d = c.elementAt(rand.nextInt(c.length));
          assign(s, d);
        }
      }
    }

    search(random: true);
  }

  void _setup(Iterable<int> clues) {
    techniques = [];

    for (var s in squares) {
      _candidates[s] = Candidates();
    }

    for (int i = 0; i < clues.length; i++) {
      if (clues.elementAt(i) > 0) {
        if (!assign(squares[i], clues.elementAt(i))) break;
      }
    }
  }

  @override
  String toString() {
    return squares.map((s) => candidates(s).digit).join('');
  }

  bool assign(Square s, int d, [CandidateState? state]) {
    final candidates = state ?? _candidates;
    final others = candidates[s]!.remove(d);
    for (var d2 in others.each()) {
      if (!eliminate(s, d2, state)) return false;
    }
    return true;
  }

  bool eliminate(Square s, int d, [CandidateState? state]) {
    final candidates = state ?? _candidates;
    var c = candidates[s]!;
    // Already removed
    if (!c.has(d)) return true;
    // print('Eliminate $d from $s');
    c = _candidates[s] = c.remove(d);
    // All candidates removed, a contradiction
    if (c.isEmpty) {
      // print('Contradiction eliminating $d from $s');
      return false;
    }

    // Only one candidate remains, propagate its removal from peers
    // Naked singles
    if (c.isSingle) {
      // print('Single candidate $d in $s');
      techniques.add(NakedSingle('for $d in $s'));
      for (var peer in s.peers) {
        if (!eliminate(peer, c.digit)) return false;
      }
    }

    // Check if the square's units now only have 1 place d can be put
    // Hidden singles
    for (final unit in s.units) {
      final dPlaces = unit.squares.where((s) => candidates[s]!.has(d));
      if (dPlaces.isEmpty) {
        // print('Contradiction: $unit has no place for $d');
        // display();
        return false;
      } else if (dPlaces.length == 1 && !candidates[dPlaces.first]!.isSingle) {
        // print('Hidden single $d in $unit');
        techniques.add(HiddenSingle('for $d in $s of $unit'));
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

  bool solve() {
    final stopwatch = Stopwatch()..start();
    final result = applyLogic();
    stopwatch.stop();
    print(stopwatch.elapsed);
    return result;
  }

  bool applyLogic() {
    final List<Technique? Function()> logicOrder = [
      () => nakedSubset(pairs),
      () => hiddenSubset(pairs),
      () => nakedSubset(triplets),
      () => hiddenSubset(triplets),
      () => xWings(rows, cols),
      () => xWings(cols, rows),
      singlesChain,
      () => nakedSubset(quads),
      () => hiddenSubset(quads),
      yWings,
      () => swordfish(rows, cols),
      () => swordfish(cols, rows),
      xyzWings,
      xCycles,
      medusa,
      () => jellyfish(rows, cols),
      () => jellyfish(cols, rows),
      uniqueRect,
      forcingChain,
    ];
    Technique? result = None();
    var round = 0;
    while (result != null && !isSolved()) {
      round++;

      for (var i = 0; i < logicOrder.length; i++) {
        result = logicOrder[i]();
        if (result is None) continue;
        if (result is Technique) {
          techniques.add(result);
        }
        // If it was null, or applied a technique, we break the for to restart logic order
        break;
      }

      // All logic ran with no technique applied
      if (result is None) {
        return false;
      }
    }
    return true;
  }

  CandidateState? search({int n = 0, random = false}) {
    // if (state == null) return null;
    if (isSolved()) return _candidates;

    // Pick the cell with the least remaining candidates and try out each
    var x = squares.where((s) => _candidates[s]!.length > 1).toList();

    if (random) {
      shuffle(x);
    } else {
      x = x.sorted((a, b) => candidates(a).length - candidates(b).length);
    }

    final s = x.first;

    var original = _candidates;
    for (var d in candidates(s).each()) {
      _candidates = copy();
      if (assign(s, d) && search(n: n + 1) != null) {
        return _candidates;
      }
      _candidates = original;
    }

    return null;
  }

  int countSolutions({n = 0, count = 0}) {
    // if (state == null) return null;
    if (isSolved()) return count + 1;

    final s = squares.firstWhereOrNull((s) => candidates(s).length > 1)!;

    var original = _candidates;
    for (var d in candidates(s).each()) {
      _candidates = copy();
      if (assign(s, d)) {
        count += countSolutions(n: n + 1);
        _candidates = original;
        if (count > 1) return 2;
      }
      _candidates = original;
    }

    return 0;
  }

  solveBrute() {
    final stopwatch = Stopwatch()..start();
    search();
    stopwatch.stop();
    display();
    print(stopwatch.elapsed);
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

  CandidateState copy() {
    return _candidates.map((s, c) => MapEntry(s, Candidates(c.value)));
  }
}
