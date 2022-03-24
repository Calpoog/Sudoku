import 'dart:math';

import 'package:collection/collection.dart';

import 'technique.dart';

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

  String simple() => '';
}

class Row extends Unit {
  Row(int index) : super(index);

  @override
  String toString() {
    return 'Row ${index + 1}';
  }

  @override
  String simple() => String.fromCharCode(index + 65);
}

class Column extends Unit {
  Column(int index) : super(index);

  @override
  String toString() {
    return 'Col ${index + 1}';
  }

  @override
  String simple() => (index + 1).toString();
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
        if (!assign(squares[i], clues.elementAt(i))) break;
      }
    }
  }

  factory Solution.fromString(String grid) {
    final g = grid.replaceAll('.', '0').replaceAll(RegExp(r'[^\d]'), '').split('').map((d) => int.parse(d));
    return Solution._internal(g)..solve();
  }

  bool assign(Square s, int d) {
    final others = candidates[s]!.remove(d);
    for (var d2 in others.each()) {
      if (!eliminate(s, d2)) return false;
    }
    return true;
  }

  bool eliminate(Square s, int d) {
    var c = candidates[s]!;
    // Already removed
    if (!c.has(d)) return true;
    // print('Eliminate $d from $s');
    c = candidates[s] = c.remove(d);
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
      final dPlaces = unit.squares.where((s) => candidates[s]!.has(d));
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

  Technique? nakedSubset() {
    for (var unit in units) {
      for (var combo in combos) {
        var matches = <Square>[];
        for (var s in unit.squares) {
          if (!candidates[s]!.isSingle && candidates[s]!.hasOnlyAny(combo)) matches.add(s);
        }

        if (matches.length == combo.length) {
          var affected = unit.squares.where((s) => !matches.contains(s));
          if (union(affected).hasAny(combo)) {
            for (var s in affected) {
              for (var d in combo.each()) {
                if (!eliminate(s, d)) return null;
              }
            }
            return NakedSubset('Naked subset $combo found in $unit');
          }
        }
      }
    }

    return None();
  }

  Technique? hiddenSubset() {
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
          for (var s in matches) {
            for (var d = 1; d <= 9; d++) {
              if (!combo.has(d)) {
                if (!eliminate(s, d)) return null;
              }
            }
          }
          return HiddenSubset('Hidden subset $combo found in $unit');
        }
      }
    }

    return None();
  }

  Technique? pointingPairs() {
    for (var b = 0; b < boxes.length; b++) {
      final box = boxes[b];
      // A list where the index corresponds to a digit, and the values tell which row/col it's in
      // 0, single-row: 2, 3, 4 multi-row: 5, 6, 7, 9
      final dRows = List.filled(9, 0);
      final dCols = List.filled(9, 0);
      for (var i = 0; i < 3; i++) {
        for (var isRow in [true, false]) {
          final squares = box.squares.split((s) => (isRow ? s.row : s.col) % 3 == i && !candidates[s]!.isSingle);
          final boxLine = union(squares.match);
          final dLines = isRow ? dRows : dCols;
          for (var d = 1; d <= 9; d++) {
            if (boxLine.has(d)) {
              dLines[d - 1] += i + 2;
              var restOfBox = box.squares.where((s) => !squares.match.contains(s));
              if (!union(squares.rest).has(d) && union(restOfBox).has(d)) {
                for (var s in restOfBox) {
                  if (!eliminate(s, d)) return null;
                }
                return BoxLineIntersection(
                    'Box/Line reduction $d between $box and ${isRow ? 'Row' : 'Col'} ${i + 1 + (isRow ? box.rowOffset : box.colOffset)}');
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
            if (union(rest).has(d)) {
              for (var s in rest) {
                if (!eliminate(s, d)) return null;
              }
              return PointingPair(
                  'Pointing pair $d between $box and ${isRow ? 'Row' : 'Col'} ${index + 1 + (isRow ? box.rowOffset : box.colOffset)}');
            }
          }
        }
      }
    }

    return None();
  }

  Technique? xWings(List<Unit> primary, List<Unit> secondary) {
    final result = xFish(primary, secondary, 2);
    if (result == null) return null;
    return result == '' ? None() : XWing('Xwing $result');
  }

  Technique? yWings([bool useZ = false]) {
    final hinges = squares.where((s) => candidates[s]!.length == (useZ ? 3 : 2));
    final pincers = useZ ? squares.where((s) => candidates[s]!.length == 2) : hinges;

    for (var i = 0; i < hinges.length; i++) {
      final hinge = hinges.elementAt(i);
      for (var j = useZ ? 0 : i + 1; j < pincers.length; j++) {
        final pincer1 = pincers.elementAt(j);
        if (_isPincer(hinge, pincer1, useZ)) {
          for (var k = j + 1; k < pincers.length; k++) {
            final pincer2 = pincers.elementAt(k);
            if (_isPincer(hinge, pincer2, useZ)) {
              // If it's also a pincer of the hinge, we know p1 and p2 share 1 value with pivot.
              // So they must share a value, and that value must not be in pivot.
              final shared = candidates[pincer1]!.intersection(candidates[pincer2]!);
              if (shared.isSingle && (useZ || !candidates[hinge]!.hasAll(shared))) {
                var sees = pincer1.peers.where((s) => pincer2.peers.contains(s) && candidates[s]!.has(shared.digit));
                if (useZ) sees = sees.where((s) => hinge.peers.contains(s));
                if (sees.isNotEmpty) {
                  display();
                  for (var s in sees) {
                    if (!eliminate(s, shared.digit)) return null;
                  }
                  final message = 'for $shared in $hinge, $pincer1, $pincer2';
                  return useZ ? XYZWing('XYZWing $message') : YWing('YWing $message');
                }
              }
            }
          }
        }
      }
    }

    return None();
  }

  bool _isPincer(Square hinge, Square pincer, bool useZ) {
    return pincer != hinge &&
        !candidates[hinge]!.equals(candidates[pincer]!) &&
        (useZ ? candidates[hinge]!.hasAll(candidates[pincer]!) : candidates[hinge]!.hasAny(candidates[pincer]!)) &&
        hinge.peers.contains(pincer);
  }

  Technique? singlesChain() {
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
                if (!_removeColor(candidates, d, group, CandidateColor.green)) return null;
                return SinglesChain('Green $d appears twice in $unit with chain $group');
              }
              if (unitReds[unit] == true) {
                final result = _removeUncolored(d, group, unit);
                if (result is! None) return result;
              }
              unitGreens[unit] = true;
            } else {
              if (unitReds[unit] == true) {
                if (!_removeColor(candidates, d, group, CandidateColor.red)) return null;
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
    return candidates[s]!.has(d) && !chain.any((c) => c.square == s);
  }

  Iterable<Square> _getUncolored(int d, Iterable<ColoredCandidate> chain, Iterable<Square> squares) {
    return squares.where((s) => _isUncolored(d, chain, s));
  }

  bool _removeColor(CandidateState candidates, int d, Iterable<ColoredCandidate> chain, CandidateColor color) {
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
    // A list of branches that were of length 1, that get revisted to be colored
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

  Technique? swordfish(List<Unit> primary, List<Unit> secondary) {
    final result = xFish(primary, secondary, 3);
    if (result == null) return null;
    return result == '' ? None() : Swordfish('Swordfish $result');
  }

  Technique? jellyfish(List<Unit> primary, List<Unit> secondary) {
    final result = xFish(primary, secondary, 4);
    if (result == null) return null;
    return result == '' ? None() : Jellyfish('Jellyfish $result');
  }

  String? xFish(List<Unit> primary, List<Unit> secondary, [int size = 2]) {
    final isRow = primary.first is Row;
    for (var d = 1; d <= 9; d++) {
      final maskedPrimary = primary.map((line) => _maskLine(line, d)).toList();

      // Find lines that could be part of an XWing, Swordfish, Jellyfish
      final lines = <Unit>[];
      for (var i = 0; i < primary.length; i++) {
        final line = maskedPrimary[i];
        if (line.length <= size && line.length >= 2) {
          lines.add(primary[i]);
        }
      }

      for (var combo in combinations(lines, size)) {
        final counts = <int, int>{};

        // There should be a minimum of 2 in the cross-axis direction
        for (var line in combo) {
          for (var j = 0; j < primary.length; j++) {
            if (candidates[line.squares[j]]!.has(d)) {
              if (!counts.containsKey(j)) counts[j] = 0;
              counts[j] = counts[j]! + 1;
            }
          }
        }

        // There should be exactly size non-zero counts, and they must all be >= 2
        var affected = <Square>[];
        if (counts.length != size) continue;

        counts.removeWhere((key, value) => value < 2);
        for (var c in counts.keys) {
          affected.addAll(secondary[c]
              .squares
              .where((s) => candidates[s]!.has(d) && !combo.contains(primary[isRow ? s.row : s.col])));
        }
        if (affected.isNotEmpty) {
          display();
          for (var s in affected) {
            if (!eliminate(s, d)) return null;
          }
          final p = combo.map((c) => c.simple()).join('');
          final s = counts.keys.sorted((a, b) => a - b).map((k) => secondary[k].simple()).join('');
          final location = isRow ? [p, s] : [s, p];
          return '${combo.map((l) => maskedPrimary[l.index].length).join('-')} for $d in ${location.join('')}';
        }
      }
    }

    return '';
  }

  /// Creates a Candidates bitmask that instead represents the locations of d in the line
  Candidates _maskLine(Unit line, int d) {
    return line.squares.foldIndexed<Candidates>(Candidates(0),
        (i, previous, s) => candidates[s]!.has(d) ? Candidates(previous.value | (1 << 8 - i)) : previous);
  }

  Candidates union(Iterable<Square> squares) {
    return squares.fold<Candidates>(Candidates(0), (previous, s) => candidates[s]!.union(previous));
  }

  void display() {
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

  bool isSolved() {
    return candidates.values.every((c) => c.isSingle);
  }

  solve() {
    final stopwatch = Stopwatch()..start();
    final result = applyLogic();
    stopwatch.stop();
    if (result) {
      print('RESULT:');
      display();
    } else {
      print('Unsolvable');
    }
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
      () => yWings(true),
      () => jellyfish(rows, cols),
      () => jellyfish(cols, rows),
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
          // First technique doesn't need rerun when it hits because constraint prop happens implicitly
          print(result.message);
          if (i > 0) break;
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
