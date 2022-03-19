import 'dart:math';

import 'package:collection/collection.dart';

final counts = {1: 9, 2: 9, 3: 9, 4: 9, 5: 9, 6: 9, 7: 9, 8: 9, 9: 9};
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

typedef CandidateState = Map<Square, Candidates>;

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

class Candidates {
  int value;

  Candidates([int? candidates]) : value = candidates ?? allDigits;

  bool has(int i) {
    return value & digitsBitmask[i]! > 0;
  }

  bool hasAll(Candidates other) {
    return other.value == value & other.value;
  }

  bool hasAny(Candidates other) {
    return value & other.value > 0;
  }

  /// Whether there are candidates other than in `other`
  bool hasOthers(Candidates other) {
    return value & ~other.value > 0;
  }

  /// Has only a subset of `other` and nothing else
  bool hasOnlyAny(Candidates other) => hasAny(other) && !hasOthers(other);

  Iterable<int> each() {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9].where((d) => has(d));
  }

  bool get isEmpty => value == 0;

  bool get isSingle {
    return value > 0 && (value & (value - 1)) == 0;
  }

  int get length {
    int x = value;
    x -= ((x >> 1) & 0x55555555);
    x = (((x >> 2) & 0x33333333) + (x & 0x33333333));
    x = (((x >> 4) + x) & 0x0f0f0f0f);
    x += (x >> 8);
    x += (x >> 16);
    return (x & 0x0000003f);
  }

  Candidates union(Candidates other) => Candidates(value | other.value);

  Candidates unique(Candidates other) => Candidates(value ^ other.value);

  Candidates remove(int d) {
    return Candidates(value & ~digitsBitmask[d]!);
  }

  Candidates removeAll(Candidates other) {
    return Candidates(value & ~other.value);
  }

  bool equals(Candidates other) {
    return value == other.value;
  }

  @override
  String toString() {
    return each().join('');
  }
}

class Unit {
  final int index;

  /// The squares in the unit.
  final List<Square> squares = [];

  /// A mapping of digit to its count in the unit
  final Map<int, int> count = Map.from(counts);

  Unit(this.index);

  Iterable<Square> where(bool Function(Square) test) {
    return squares.where(test);
  }
}

class Row extends Unit {
  Row(int index) : super(index);

  @override
  String toString() {
    return 'Row ${index + 1}';
  }
}

class Column extends Unit {
  Column(int index) : super(index);

  @override
  String toString() {
    return 'Col ${index + 1}';
  }
}

class Box extends Unit {
  final int rowOffset;
  final int colOffset;

  Box(int index)
      : rowOffset = (index / 3).floor() * 3,
        colOffset = index % 3 * 3,
        super(index);

  @override
  String toString() {
    return 'Box ${index + 1}';
  }
}

class Square {
  final int index;
  final int row;
  final int col;
  final List<Square> peers = [];
  final List<Unit> units = [];

  Square({required this.col, required this.row, required this.index});

  @override
  String toString() {
    return String.fromCharCode(row + 65) + (col + 1).toString();
  }
}

class Solution {
  bool isComplete = false;
  bool isFailed = false;
  final List<Row> rows = List.generate(9, (index) => Row(index));
  final List<Column> cols = List.generate(9, (index) => Column(index));
  final List<Box> boxes = List.generate(9, (index) => Box(index));
  late final List<Unit> units = [];
  CandidateState candidates = {};

  /// A map of [Square]s to int representing its candidates as a bitmask
  /// 100101011 = 1..4.6.89
  // final CandidateState candidates = {};
  late final List<Square> squares;

  Solution._internal(Iterable<int> clues) {
    squares = List.generate(81, (i) {
      final row = (i / 9).floor();
      final col = i % 9;
      final box = (row / 3).floor() * 3 + (col / 3).floor();
      final square = Square(row: row, col: col, index: i);
      rows[row].squares.add(square);
      cols[col].squares.add(square);
      boxes[box].squares.add(square);
      square.units.addAll([rows[row], cols[col], boxes[box]]);
      candidates[square] = Candidates(allDigits);
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
        if (assign(candidates, squares[i], clues.elementAt(i)) == null) break;
      }
    }
  }

  factory Solution.fromString(String grid) {
    final g = grid.replaceAll('.', '0').replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => int.parse(d));
    return Solution._internal(g)..solve();
  }

  CandidateState? assign(CandidateState candidates, Square s, int d) {
    final others = candidates[s]!.remove(d);
    for (var d2 in others.each()) {
      if (eliminate(candidates, s, d2) == null) return null;
    }
    return candidates;
  }

  CandidateState? eliminate(CandidateState candidates, Square s, int d) {
    var c = candidates[s]!;
    // Already removed
    if (!c.has(d)) return candidates;
    c = candidates[s] = c.remove(d);
    // All candidates removed, a contradiction
    if (c.isEmpty) {
      print('PROBLEM???');
      return null;
    }
    // Only one candidate remains, propagate its removal from peers
    if (c.isSingle) {
      for (var peer in s.peers) {
        if (eliminate(candidates, peer, bitmaskDigits[c.value]!) == null) return null;
      }
    }

    // Check if the square's units now only have 1 place d can be put
    for (final unit in s.units) {
      final dPlaces = unit.where((s) => candidates[s]!.has(d));
      if (dPlaces.isEmpty) {
        isFailed = true;
      } else if (dPlaces.length == 1) {
        if (assign(candidates, dPlaces.first, d) == null) return null;
      }
    }

    return candidates;
  }

  CandidateState? nakedSubset(CandidateState? candidates) {
    if (candidates == null) return null;
    if (isSolved(candidates)) return candidates;

    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        for (var s in unit.squares) {
          if (!candidates[s]!.isSingle && candidates[s]!.hasOnlyAny(combo)) matches.add(s);
        }

        if (matches.length == combo.length) {
          var affected = unit.squares.where((s) => !matches.contains(s));
          if (union(candidates, affected).hasAny(combo)) {
            print('Naked subset $combo found in $unit');
            display(candidates);
            for (var s in affected) {
              for (var d in combo.each()) {
                if (eliminate(candidates, s, d) == null) return null;
              }
            }
          }
        }
      }
    }

    return candidates;
  }

  CandidateState? hiddenSubset(CandidateState? candidates) {
    if (candidates == null) return null;
    if (isSolved(candidates)) return candidates;

    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        // This needs to end up containing the combo. e.g. we union up the subset
        // matches, so we make sure it doesn't just find 1,1,1 as a "triplet". It
        // also tells us when its length > combo.length that there were other
        // candidates present that prove it was "hidden."
        var foundCandidates = Candidates(0);

        for (var s in unit.squares) {
          if (!candidates[s]!.isSingle && candidates[s]!.hasAny(combo)) {
            matches.add(s);
            foundCandidates = foundCandidates.union(candidates[s]!);
          }
        }

        if (matches.length == combo.length && foundCandidates.hasAll(combo) && !foundCandidates.equals(combo)) {
          print('Hidden subset $combo found in $unit');
          display(candidates);
          for (var s in matches) {
            for (var d = 1; d <= 9; d++) {
              if (!combo.has(d)) {
                if (eliminate(candidates, s, d) == null) return null;
              }
            }
          }
        }
      }
    }

    return candidates;
  }

  CandidateState? pointingPairs(CandidateState? candidates) {
    if (candidates == null) return null;
    if (isSolved(candidates)) return candidates;

    for (var b = 0; b < boxes.length; b++) {
      final box = boxes[b];
      // A list where the index corresponds to a digit, and the values tell which row/col it's in
      // 0, single-row: 2, 3, 4 multi-row: 5, 6, 7, 9
      final dRows = List.filled(9, 0);
      final dCols = List.filled(9, 0);
      for (var i = 0; i < 3; i++) {
        for (var isRow in [true, false]) {
          final squares = box.squares.split((s) => (isRow ? s.row : s.col) % 3 == i && !candidates[s]!.isSingle);
          final boxLine = union(candidates, squares.match);
          final dLines = isRow ? dRows : dCols;
          for (var d = 1; d <= 9; d++) {
            if (boxLine.has(d)) {
              dLines[d - 1] += i + 2;
              var restOfBox = box.where((s) => !squares.match.contains(s));
              if (!union(candidates, squares.rest).has(d) && union(candidates, restOfBox).has(d)) {
                print('Box/Line reduction $d in ${isRow ? 'row' : 'col'} ${i + 1} of $box');
                display(candidates);
                for (var s in restOfBox) {
                  if (eliminate(candidates, s, d) == null) return null;
                }
              }
            }
          }
        }
      }
      for (var d = 1; d <= 9; d++) {
        List<Square> affected = [];
        for (var isRow in [true, false]) {
          final lines = isRow ? rows : cols;
          final dLines = isRow ? dRows : dCols;
          final offset = isRow ? box.rowOffset : box.colOffset;
          final index = dLines[d - 1] - 2;

          // If d is only in one row/col of the box it's a pointing pair
          if ([2, 3, 4].contains(dLines[d - 1])) {
            var rest = lines[index + offset].where((s) => !s.units.contains(box));
            if (union(candidates, rest).has(d)) {
              affected.addAll(rest);
              print('Pointing pair $d in ${isRow ? 'row' : 'col'} ${index + 1} of $box');
              display(candidates);
            }
          }
          // If d isn't just in this row/col of the box but it *is* the only ds
          // in the whole row/col, it's a box/line reduction
          // else if(!dIsInRest) {
          //     rest = box.where((s) => s.row != index + box.rowOffset);
          //     if (union(candidates, rest).has(d)) {
          //       affected.addAll(rest);
          //       print('Box/Line reduction $d in ${isRow ? 'row': 'col'} ${index + 1} of $box');
          //       display(candidates);
          //     }
          //   }
        }

        for (var s in affected) {
          if (eliminate(candidates, s, d) == null) return null;
        }
      }
    }

    return candidates;
  }

  Candidates union(CandidateState candidates, Iterable<Square> squares) {
    return squares.fold<Candidates>(Candidates(0), (previous, s) => candidates[s]!.union(previous));
  }

  void display(CandidateState candidates) {
    final width = 2 + (squares.map((s) => candidates[s]!.length)).reduce(max);
    final line = '\n' + List.filled(3, List.filled(width * 3, '-').join('')).join('+');
    var result = '';
    for (var s in squares) {
      final val = candidates[s]!.toString();
      final pad = (width - val.length) / 2;
      result += val.padLeft(val.length + pad.ceil()).padRight(width);
      if (s.col == 2 || s.col == 5) result += '|';
      if ((s.row == 2 || s.row == 5) && s.col == 8) result += line;
      if (s.col == 8) result += '\n';
    }
    print(result + '\n\n\n.');
  }

  bool isSolved(CandidateState candidates) {
    return candidates.values.every((c) => c.isSingle);
  }

  solve() {
    final stopwatch = Stopwatch()..start();
    final result = search(applyLogic(candidates));
    stopwatch.stop();
    if (result == null) {
      print('Unsolvable');
    } else {
      print('RESULT:');
      display(result);
    }
    print(stopwatch.elapsed);
  }

  CandidateState? applyLogic(CandidateState? candidates) {
    return hiddenSubset(nakedSubset(pointingPairs(candidates)));
  }

  CandidateState? search(CandidateState? candidates, [int n = 0]) {
    if (candidates == null) return null;
    if (isSolved(candidates)) return candidates;
    print('Search $n');

    // Pick the cell with the least remaining candidates and try out each
    final x = squares.where((s) => candidates[s]!.length > 1);

    final s = x.sorted((a, b) => candidates[a]!.length - candidates[b]!.length).first;

    for (var d in candidates[s]!.each()) {
      print('Trying $d for $s');
      var result = search(applyLogic(assign(copy(candidates), s, d)), n + 1);
      print('Up to $n');
      if (result != null) return result;
    }
    return null;
  }

  CandidateState copy(CandidateState candidates) {
    return candidates.map((s, c) => MapEntry(s, Candidates(c.value)));
  }
}
