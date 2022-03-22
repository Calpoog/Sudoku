import 'dart:math';

import 'package:collection/collection.dart';

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

typedef CandidateState = Map<Square, Candidates>;

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

  int get digit {
    assert(isSingle);
    return bitmaskDigits[value]!;
  }

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

  Candidates intersection(Candidates other) => Candidates(value & other.value);

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

  Unit(this.index);
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

  /// Whether the last logic attempt was applied
  bool applied = false;
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
      print('Contradiction eliminating $d from $s');
      display(candidates);
      return null;
    }
    // Only one candidate remains, propagate its removal from peers
    if (c.isSingle) {
      for (var peer in s.peers) {
        if (eliminate(candidates, peer, c.digit) == null) return null;
      }
    }

    // Check if the square's units now only have 1 place d can be put
    for (final unit in s.units) {
      final dPlaces = unit.squares.where((s) => candidates[s]!.has(d));
      if (dPlaces.isEmpty) {
        isFailed = true;
      } else if (dPlaces.length == 1) {
        if (assign(candidates, dPlaces.first, d) == null) return null;
      }
    }

    return candidates;
  }

  CandidateState? nakedSubset(CandidateState candidates) {
    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        for (var s in unit.squares) {
          if (!candidates[s]!.isSingle && candidates[s]!.hasOnlyAny(combo)) matches.add(s);
        }

        if (matches.length == combo.length) {
          var affected = unit.squares.where((s) => !matches.contains(s));
          if (union(candidates, affected).hasAny(combo)) {
            apply('Naked subset $combo found in $unit');
            for (var s in affected) {
              for (var d in combo.each()) {
                if (eliminate(candidates, s, d) == null) return null;
              }
            }
            return candidates;
          }
        }
      }
    }

    return candidates;
  }

  CandidateState? hiddenSubset(CandidateState candidates) {
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
          apply('Hidden subset $combo found in $unit');
          for (var s in matches) {
            for (var d = 1; d <= 9; d++) {
              if (!combo.has(d)) {
                if (eliminate(candidates, s, d) == null) return null;
              }
            }
          }
          return candidates;
        }
      }
    }

    return candidates;
  }

  CandidateState? pointingPairs(CandidateState candidates) {
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
              var restOfBox = box.squares.where((s) => !squares.match.contains(s));
              if (!union(candidates, squares.rest).has(d) && union(candidates, restOfBox).has(d)) {
                apply(
                    'Box/Line reduction $d between $box and ${isRow ? 'Row' : 'Col'} ${i + 1 + (isRow ? box.rowOffset : box.colOffset)}');
                for (var s in restOfBox) {
                  if (eliminate(candidates, s, d) == null) return null;
                }
                return candidates;
              }
            }
          }
        }
      }
      for (var d = 1; d <= 9; d++) {
        for (var isRow in [true, false]) {
          final lines = isRow ? rows : cols;
          final dLines = isRow ? dRows : dCols;
          final offset = isRow ? box.rowOffset : box.colOffset;
          final index = dLines[d - 1] - 2;

          // If d is only in one row/col of the box it's a pointing pair
          if ([2, 3, 4].contains(dLines[d - 1])) {
            var rest = lines[index + offset].squares.where((s) => !s.units.contains(box));
            if (union(candidates, rest).has(d)) {
              apply(
                  'Pointing pair $d between $box and ${isRow ? 'Row' : 'Col'} ${index + 1 + (isRow ? box.rowOffset : box.colOffset)}');
              for (var s in rest) {
                if (eliminate(candidates, s, d) == null) return null;
              }
              return candidates;
            }
          }
        }
      }
    }

    return candidates;
  }

  CandidateState? xWings(CandidateState candidates, List<Unit> primary, List<Unit> secondary) {
    for (var d = 1; d <= 9; d++) {
      for (var i = 0; i < primary.length; i++) {
        final line = primary[i];
        final spots = [];
        for (var x = 0; x < line.squares.length; x++) {
          final s = line.squares[x];
          if (!candidates[s]!.isSingle && candidates[s]!.has(d)) spots.add(x);
          if (spots.length > 2) break;
        }
        // If there was a pair, look through the rest of the lines for the same pair
        if (spots.length == 2) {
          for (var j = i + 1; j < primary.length; j++) {
            final otherLine = primary[j];
            var matches = true;
            for (var x = 0; x < otherLine.squares.length; x++) {
              final s = otherLine.squares[x];
              final isPairSpot = spots.contains(x);
              final spotHasDigit = candidates[s]!.has(d);
              // If a pair spot doesn't have the digit, or a non-pair spot does, this line isn't a match
              if (isPairSpot ^ spotHasDigit) {
                matches = false;
                break;
              }
            }
            if (matches) {
              var spot1SecondaryLine = secondary[spots[0]].squares.whereIndexed((x, s) => x != i && x != j);
              var spot2SecondaryLine = secondary[spots[1]].squares.whereIndexed((x, s) => x != i && x != j);
              if (union(candidates, spot1SecondaryLine).has(d) && union(candidates, spot2SecondaryLine).has(d)) {
                apply(
                    'XWing for $d in ${line.runtimeType}s ${i + 1} and ${j + 1}, squares ${spots[0] + 1}, ${spots[1] + 1}');
                for (var s in [...spot1SecondaryLine, ...spot2SecondaryLine]) {
                  if (eliminate(candidates, s, d) == null) return null;
                }
                return candidates;
              }
            }
          }
        }
      }
    }

    return candidates;
  }

  CandidateState? yWings(CandidateState candidates) {
    final twos = squares.where((s) => candidates[s]!.length == 2);

    for (var i = 0; i < twos.length; i++) {
      final pivot = twos.elementAt(i);
      for (var j = i + 1; j < twos.length; j++) {
        final pincer1 = twos.elementAt(j);
        if (_isPincer(candidates, pivot, pincer1)) {
          for (var k = j + 1; k < twos.length; k++) {
            final pincer2 = twos.elementAt(k);
            if (_isPincer(candidates, pivot, pincer2)) {
              // If it's also a pincer of the pivot, we know p1 and p2 share 1 value with pivot.
              // So they must share a value, and that value must not be in pivot.
              final shared = candidates[pincer1]!.intersection(candidates[pincer2]!);
              if (shared.isSingle && !candidates[pivot]!.hasAll(shared)) {
                final sees = pincer1.peers.where((s) => pincer2.peers.contains(s) && candidates[s]!.has(shared.digit));
                if (sees.isNotEmpty) {
                  apply('YWing for $shared in $pivot, $pincer1, $pincer2');
                  for (var s in sees) {
                    if (eliminate(candidates, s, shared.digit) == null) return null;
                  }
                  return candidates;
                }
              }
            }
          }
        }
      }
    }

    return candidates;
  }

  bool _isPincer(CandidateState candidates, Square pivot, Square pincer) {
    return pincer != pivot &&
        !candidates[pivot]!.equals(candidates[pincer]!) &&
        candidates[pivot]!.hasAny(candidates[pincer]!) &&
        pivot.peers.contains(pincer);
  }

  CandidateState? singlesChain(CandidateState candidates) {
    for (var d = 1; d <= 9; d++) {
      final colors = <ColoredCandidate>{};

      for (var unit in units) {
        final dInUnit = unit.squares.where((s) => candidates[s]!.has(d)).map((s) => s);
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
        if (_doColoring(candidates, colored, groupId) > 0) groupId++;
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
                apply('Green $d appears twice in $unit with chain $group');
                if (_removeColor(candidates, d, group, CandidateColor.green) == null) return null;
                return candidates;
              }
              if (unitReds[unit] == true && _removeUncolored(candidates, d, group, unit) == null) return null;
              unitGreens[unit] = true;
            } else {
              if (unitReds[unit] == true) {
                apply('Red $d appears twice in $unit with chain $group');
                if (_removeColor(candidates, d, group, CandidateColor.red) == null) return null;
                return candidates;
              }
              if (unitGreens[unit] == true && _removeUncolored(candidates, d, group, unit) == null) return null;
              unitReds[unit] = true;
            }

            // If any uncolored square in this unit "sees" both colors, it gets eliminated
            for (var s in unit.squares) {
              if (_isUncolored(candidates, d, group, s)) {
                if (!uncoloredSees.containsKey(s)) {
                  uncoloredSees[s] = isGreen ? true : false;
                }
                // Sees both
                else if ((uncoloredSees[s] == false && isGreen) || (uncoloredSees[s] == true && !isGreen)) {
                  apply('Uncolored $d in $s sees red and green in chain $group');
                  if (eliminate(candidates, s, d) == null) return null;
                  return candidates;
                }
              }
            }
          }
        }
      }
    }

    return candidates;
  }

  bool _isUncolored(CandidateState candidates, int d, Iterable<ColoredCandidate> chain, Square s) {
    return candidates[s]!.has(d) && !chain.any((c) => c.square == s);
  }

  Iterable<Square> _getUncolored(
      CandidateState candidates, int d, Iterable<ColoredCandidate> chain, Iterable<Square> squares) {
    return squares.where((s) => _isUncolored(candidates, d, chain, s));
  }

  CandidateState? _removeColor(
      CandidateState candidates, int d, Iterable<ColoredCandidate> chain, CandidateColor color) {
    for (var c in chain) {
      if (eliminate(candidates, c.square, d) == null) return null;
    }
    return candidates;
  }

  CandidateState? _removeUncolored(CandidateState candidates, int d, Iterable<ColoredCandidate> chain, Unit unit) {
    var uncolored = _getUncolored(candidates, d, chain, unit.squares);
    if (uncolored.isNotEmpty) {
      apply('Opposite colors for $d in $unit, with chain $chain');
      for (var s in uncolored) {
        if (eliminate(candidates, s, d) == null) return null;
      }
    }
    return candidates;
  }

  // Traverses the chain and returns how far it got (because the chains have to be length > 2)
  int _doColoring(CandidateState candidates, ColoredCandidate start, int group, [int depth = 0]) {
    if (start.visited) return 0;

    start.color = CandidateColor.uncolored;
    start.group = group;

    var length = depth;
    // A list of branches that were of length 1, that get revisted to be colored
    // if this node ends up as part of a valid length chain
    var shortBranches = <ColoredCandidate>[];
    for (var pair in start.pairs) {
      var branchLength = _doColoring(candidates, pair, group, depth + 1);
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
    final result = applyLogic(candidates);
    stopwatch.stop();
    if (result == null) {
      print('Unsolvable');
    } else {
      print('RESULT:');
      display(result);
    }
    print(stopwatch.elapsed);
  }

  void apply(String message) {
    print(message);
    display(candidates);
    applied = true;
  }

  CandidateState? applyLogic(CandidateState candidates) {
    final List<Function> logicOrder = [
      hiddenSubset,
      pointingPairs,
      (CandidateState candidates) => xWings(candidates, rows, cols),
      (CandidateState candidates) => xWings(candidates, cols, rows),
      yWings,
      singlesChain,
    ];
    CandidateState? result = candidates;
    var round = 0;
    while (result != null && !isSolved(result)) {
      round++;
      print('Round $round of logic');
      result = nakedSubset(result);

      for (var f in logicOrder) {
        applied = false;
        result = f(result);
        print('applied $applied');
        if (result != null && isSolved(result)) return result;
        if (result == null || applied) break;
      }

      if (result != null && !applied) {
        print('all logic failed');
        break;
      }
    }

    return result;
  }

  // CandidateState? search(CandidateState? candidates, [int n = 0]) {
  //   if (candidates == null) return null;
  //   if (isSolved(candidates)) return candidates;
  //   print('Search $n');

  //   // Pick the cell with the least remaining candidates and try out each
  //   final x = squares.where((s) => candidates[s]!.length > 1);

  //   final s = x.sorted((a, b) => candidates[a]!.length - candidates[b]!.length).first;

  //   for (var d in candidates[s]!.each()) {
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
