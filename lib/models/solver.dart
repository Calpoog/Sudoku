import 'dart:math';

import 'package:collection/collection.dart';

final counts = {1: 9, 2: 9, 3: 9, 4: 9, 5: 9, 6: 9, 7: 9, 8: 9, 9: 9};
final allDigits = int.parse('111111111', radix: 2);
final digitsBitmask = Map.fromEntries(List.generate(9, (i) => MapEntry(i + 1, 1 << 8 - i)));
final bitmaskDigits = Map.fromEntries(List.generate(9, (i) => MapEntry(1 << 8 - i, i + 1)));

typedef CandidateState = Map<Square, Candidates>;

class Candidates {
  int _c;

  Candidates([int? candidates]) : _c = candidates ?? allDigits;

  bool has(int i) {
    return _c & digitsBitmask[i]! > 0;
  }

  Iterable<int> each() {
    return [1, 2, 3, 4, 5, 6, 7, 8, 9].where((d) => has(d));
  }

  Candidates remove(int i) {
    return Candidates(_c & ~digitsBitmask[i]!);
  }

  bool get isEmpty => _c == 0;

  bool get isSingle {
    return _c > 0 && (_c & (_c - 1)) == 0;
  }

  int get length {
    int x = _c;
    x -= ((x >> 1) & 0x55555555);
    x = (((x >> 2) & 0x33333333) + (x & 0x33333333));
    x = (((x >> 4) + x) & 0x0f0f0f0f);
    x += (x >> 8);
    x += (x >> 16);
    return (x & 0x0000003f);
  }

  Candidates union(Candidates other) => Candidates(_c | other._c);

  Candidates unique(Candidates other) => Candidates(_c ^ other._c);

  @override
  String toString() {
    return each().join('');
  }
}

class Unit {
  /// The squares in the unit.
  final List<Square> squares;

  /// A mapping of digit to its count in the unit
  final Map<int, int> count = Map.from(counts);

  Unit([List<Square>? squares]) : squares = squares ?? [];

  /// Remove a count of digit
  remove(int d) {
    count[d] = count[d]! - 1;
  }

  Iterable<Square> where(bool Function(Square) test) {
    return squares.where(test);
  }
}

/// A row or column
class Line extends Unit {}

class Box extends Unit {
  final int rowOffset;
  final int colOffset;

  Box(int index)
      : rowOffset = (index / 3).floor() * 3,
        colOffset = index % 3 * 3;
}

class Square {
  final int index;
  final int row;
  final int col;
  final List<Square> peers = [];
  final List<Unit> units = [];
  Candidates candidates = Candidates();

  Square({required this.col, required this.row, required this.index});

  @override
  String toString() {
    return String.fromCharCode(row + 65) + (col + 1).toString();
  }
}

class Solution {
  bool isComplete = false;
  bool isFailed = false;
  final List<Line> rows = List.generate(9, (index) => Line());
  final List<Line> cols = List.generate(9, (index) => Line());
  final List<Box> boxes = List.generate(9, (index) => Box(index));

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
      return square;
    });

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
        assign(squares[i], clues.elementAt(i));
        if (isFailed) break;
      }
    }
  }

  Solution copy() {
    return Solution._internal(squares.map((s) => s.candidates.isSingle ? bitmaskDigits[s.candidates._c]! : 0));
  }

  factory Solution.fromString(String grid) {
    final g = grid.replaceAll('.', '0').replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => int.parse(d));
    return Solution._internal(g);
  }

  void assign(Square s, int d) {
    final others = s.candidates.remove(d);
    for (var d2 in others.each()) {
      eliminate(s, d2);
      if (isFailed) return;
    }
  }

  void eliminate(Square s, int d) {
    var c = s.candidates;
    // Already removed
    if (!c.has(d)) return;
    c = s.candidates = c.remove(d);
    // All candidates removed, a contradiction
    if (c.isEmpty) isFailed = true;
    // Only one candidate remains, propagate its removal from peers
    if (c.isSingle) {
      for (var peer in s.peers) {
        eliminate(peer, bitmaskDigits[c._c]!);
        if (isFailed) return;
      }
    }

    // Check if the square's units now only have 1 place d can be put
    for (final unit in s.units) {
      final dPlaces = unit.where((s) => s.candidates.has(d));
      if (dPlaces.isEmpty) {
        isFailed = true;
      } else if (dPlaces.length == 1) {
        assign(dPlaces.first, d);
        if (isFailed) return;
      }
    }
  }

  CandidateState? candidateLines(CandidateState? candidates) {
    // Already failed
    if (candidates == null) return null;
    // Already solved
    // if (isSolved(candidates)) return candidates;

    for (var b = 0; b < boxes.length; b++) {
      final box = boxes[b];
      // A list where the index corresponds to a digit, and the values is 0,1,2,3 depending
      // on whether the digit is ONLY in row/col none, first, second, third of the box
      final dRows = List.filled(9, 0);
      final dCols = List.filled(9, 0);
      for (var i = 0; i < 3; i++) {
        // all the candidates in this row of this box
        final row = union(box.where((s) => s.row % 3 == i && !candidates[s]!.isSingle));
        // all the candidates in this col of this box
        final col = union(box.where((s) => s.col % 3 == i && !candidates[s]!.isSingle));
        for (var d = 1; d <= 9; d++) {
          if (row.has(d)) dRows[d - 1] += i + 2;
          if (col.has(d)) dCols[d - 1] += i + 2; // 0, 2, 3, 4 : 5, 6, 7
        }
      }
      for (var d = 1; d <= 9; d++) {
        List<Square> affected = [];
        if ([2, 3, 4].contains(dRows[d - 1])) {
          final rest = rows[dRows[d - 1] - 2 + (b / 3).floor() * 3].where((s) => !s.units.contains(box));
          if (union(rest).has(d)) {
            affected.addAll(rest);
            print('candidate row ${dRows[d - 1] - 2} digit $d in box $b');
            display();
          }
        }
        if ([2, 3, 4].contains(dCols[d - 1])) {
          final rest = cols[dCols[d - 1] - 2 + b % 3 * 3].where((s) => !s.units.contains(box));
          if (union(rest).has(d)) {
            affected.addAll(rest);
            print('candidate col ${dCols[d - 1] - 2} digit $d in box $b');
            display();
          }
        }
        for (var s in affected) {
          eliminate(s, d);
        }
      }
    }

    return candidates;
  }

  Candidates union(Iterable<Square> squares) {
    return squares.fold<Candidates>(Candidates(0), (previous, s) => s.candidates.union(previous));
  }

  void display() {
    final width = 2 + (squares.map((s) => s.candidates.length)).reduce(max);
    final line = '\n' + List.filled(3, List.filled(width * 3, '-').join('')).join('+');
    var result = '';
    for (var s in squares) {
      final val = s.candidates.toString();
      final pad = (width - val.length) / 2;
      result += val.padLeft(val.length + pad.ceil()).padRight(width);
      if (s.col == 2 || s.col == 5) result += '|';
      if ((s.row == 2 || s.row == 5) && s.col == 8) result += line;
      if (s.col == 8) result += '\n';
    }
    print(result);
  }

  bool get isSolved {
    return squares.every((s) => s.candidates.isSingle);
  }
}

solve(String grid) {
  final stopwatch = Stopwatch()..start();
  final result = search(Solution.fromString(grid));
  stopwatch.stop();
  if (result == null) {
    print('Unsolvable');
  } else {
    result.display();
  }
  print(stopwatch.elapsed);
}

Solution? search(Solution solution, [int n = 0]) {
  // Already failed or solved
  if (solution.isFailed) return null;
  if (solution.isSolved) return solution;

  // Pick the cell with the least remaining candidates and try out each
  final s = solution.squares
      .where((s) => s.candidates.length > 1)
      .sorted((a, b) => a.candidates.length - b.candidates.length)
      .first;
  for (var d in s.candidates.each()) {
    var newSolution = solution.copy();
    newSolution.assign(newSolution.squares[s.index], d);
    var result = search(newSolution, n + 1);
    if (result != null) return result;
  }
  return null;
}
