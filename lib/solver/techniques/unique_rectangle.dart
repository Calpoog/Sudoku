import 'package:collection/collection.dart';

import '../candidates.dart';
import '../solver.dart';
import '../units.dart';
import 'technique.dart';

// class Rectangle {
//   final Square topLeft;
//   final Square topRight;
//   final Square bottomLeft;
//   final Square bottomRight;
//   final List<Square> floor;
//   final List<Square> roof;
// }

extension UniqueRectangleExtension on Solution {
  Technique? uniqueRect() {
    for (var pair in pairs) {
      var sPairs = squares.where((s) => candidates(s).equals(pair));
      // must be at least 2 to create a floor
      if (sPairs.length >= 2) {
        // Find any floors
        for (var i = 0; i < sPairs.length; i++) {
          final floor1 = sPairs.elementAt(i);
          for (var j = i + 1; j < sPairs.length; j++) {
            final floor2 = sPairs.elementAt(j);
            final hasSharedBox = floor1.box == floor2.box;
            final hasSharedRow = floor1.row == floor2.row;
            final hasSharedCol = floor1.col == floor2.col;
            // found a potential floor
            if (hasSharedRow || hasSharedCol) {
              final lines = hasSharedRow ? rows : cols;
              final boxLineStart = hasSharedRow ? boxes[floor1.box].rowOffset : boxes[floor1.box].colOffset;
              for (var l = 0; l < 9; l++) {
                // If floor shares a box, we look at lines outside the box for roof, otherwise
                // only lines that run though
                final isInBox = l >= boxLineStart && l < boxLineStart + 3;
                if (!(hasSharedBox ^ isInBox)) continue;
                final line = lines[l];
                final roof1 = line.squares[hasSharedRow ? floor1.col : floor1.row];
                final rc1 = candidates(roof1);
                final roof2 = line.squares[hasSharedRow ? floor2.col : floor2.row];
                final rc2 = candidates(roof2);
                // found a roof
                if (rc1.hasAll(pair) && rc2.hasAll(pair)) {
                  final extra1 = rc1.unique(pair);
                  final extra2 = rc2.unique(pair);
                  if (extra1.isEmpty && !extra2.isEmpty) return _type1(roof2, pair);
                  if (!extra1.isEmpty && extra2.isEmpty) return _type1(roof1, pair);
                  // Roof each have the same 1 extra candidate
                  if (extra2.equals(extra1)) {
                    if (extra1.isSingle) {
                      final result = _type2(roof1, roof2, extra1.digit);
                      if (result == null) return null;
                      if (result is! None) return result;
                    }
                  } else {
                    final lockedSet = extra1.union(extra2);
                    final sharedUnit = lines[hasSharedRow ? roof1.row : roof1.col];

                    // If the roof has a conjugate pair of the floor pair in a box (if they share one)
                    // or its line, then the other candidate in the pair can be removed
                    var c = Candidates(pair.value);
                    bool hasConjugate(List<Square> squares, int d) =>
                        squares.where((s) => candidates(s).has(d)).length == 2;
                    for (var p in pair.each()) {
                      if (hasConjugate(sharedUnit.squares, p) || hasConjugate(boxes[roof1.box].squares, p)) {
                        c = c.remove(p);
                        break;
                      }
                    }
                    if (c.isSingle) return _type4(roof1, roof2, c.digit);

                    // Roof have 2 other candidates
                    if (lockedSet.length == 2) {
                      // For 2C we treat this as a locked set and can make it work as a naked pair in shared unit
                      // There can only be one cell that has the locked set, otherwise a naked pair would have already
                      // eliminated these extra candidates from the unique rectangle.
                      var pairs = <Square>[];
                      var other = sharedUnit.squares.firstWhereOrNull((s) => candidates(s).equals(lockedSet));
                      var sees = <Square>{};
                      if (other != null) {
                        sees.addAll(sharedUnit.squares);
                        pairs.add(other);
                      }

                      // if the roof shares a box then we can also check box for naked pair for type 3b
                      if (hasSharedBox) {
                        other = boxes[roof1.box].squares.firstWhereOrNull((s) => candidates(s).equals(lockedSet));
                        if (other != null) {
                          sees.addAll(boxes[roof1.box].squares);
                          pairs.add(other);
                        }
                      }
                      if (sees.isEmpty) {
                        // Try looking for a triple pseudo-cell
                        final withSet = sharedUnit.squares
                            .where((s) => s != roof1 && s != roof2 && candidates(s).hasAny(lockedSet));
                        for (var d2 = 1; d2 <= 9; d2++) {
                          if (lockedSet.has(d2)) continue;
                          var triple = lockedSet.add(d2);
                          var matches = withSet.where((s) => triple.hasAll(candidates(s)));
                          if (matches.length == 2) {
                            sees.addAll(sharedUnit.squares);
                            pairs.addAll(matches);
                            break;
                          }
                        }
                      }
                      if (sees.isNotEmpty) {
                        final result = _type3(roof1, roof2, sees, lockedSet, pairs);
                        if (result == null) return null;
                        if (result is! None) return result;
                      }
                    }
                  }
                }
              }
            }
            // If we use them as a diagonal and check the other diagonal its a potential type 2C
            else {
              final diag1 = squareAt(floor1.col, floor2.row);
              final dc1 = candidates(diag1);
              final diag2 = squareAt(floor2.col, floor1.row);
              final dc2 = candidates(diag2);
              if (dc1.hasAll(pair) && dc2.hasAll(pair)) {
                final extra1 = dc1.unique(pair);
                final extra2 = dc2.unique(pair);
                // Diagonals each have the same 1 extra candidate
                if (extra2.equals(extra1) && extra1.isSingle) {
                  final result = _type2c(diag1, diag2, extra1.digit);
                  if (result == null) return null;
                  if (result is! None) return result;
                } else {
                  var c = Candidates(pair.value);
                  for (var d in pair.each()) {
                    // if it's a strong pairing to the others (all rows/cols of the square have only 2)
                    // then it's a type 5 and the weak candidate can be removed
                    var allStrong = true;
                    for (var u in [rows[diag1.row], cols[diag1.col], rows[diag2.row], cols[diag2.col]]) {
                      if (u.squares.where((s) => candidates(s).has(d)).length > 2) {
                        allStrong = false;
                        break;
                      }
                    }
                    if (allStrong) {
                      c = c.remove(d);
                      break;
                    }
                  }
                  if (c.isSingle) return _type5(floor1, floor2, c.digit);
                }
              }
            }
          }
        }
      }
    }
    return None();
  }

  // Only 1 of the corners has extra candidates, it must be one of them, so remove the pair
  Technique? _type1(Square s, Candidates pair) {
    for (var d in pair.each()) {
      if (!eliminate(s, d)) return null;
    }
    return UniqueRectangle('Type 1 UR for $pair in $s');
  }

  Technique? _type2(Square roof1, Square roof2, int d) {
    for (var unit in roof1.units) {
      if (roof2.units.contains(unit)) {
        var affected = unit.squares.where((s) => s != roof1 && s != roof2 && candidates(s).has(d)).toList();
        if (affected.isEmpty) return None();
        for (var s in affected) {
          if (!eliminate(s, d)) return null;
        }
      }
    }
    return UniqueRectangle('Type 2${roof1.box == roof2.box ? '' : 'B'} UR for $d in roof $roof1, $roof2');
  }

  Technique? _type2c(Square s1, Square s2, int d) {
    final affected = seesSquares(s1.seesUnion(s2));
    if (!union(affected).has(d)) return None();
    for (var s in affected) {
      if (!eliminate(s, d)) return null;
    }
    return UniqueRectangle('Type 2C UR for $d in diagonals $s1, $s2');
  }

  Technique? _type3(Square roof1, Square roof2, Set<Square> sees, Candidates pair, List<Square> pseudoCells) {
    var affected = sees.where((s) => s != roof1 && s != roof2 && !pseudoCells.contains(s)).toList();
    if (affected.isEmpty) return None();

    for (var s in affected) {
      for (var d in pair.each()) {
        if (!eliminate(s, d)) return null;
      }
    }
    return UniqueRectangle('Type 3 UR for $pair in roof $roof1, $roof2');
  }

  Technique? _type4(Square roof1, Square roof2, int d) {
    for (var s in [roof1, roof2]) {
      if (!eliminate(s, d)) return null;
    }
    return UniqueRectangle('Type 4 UR for $d in $roof1, $roof2');
  }

  Technique? _type5(Square diag1, Square diag2, int d) {
    for (var s in [diag1, diag2]) {
      if (!eliminate(s, d)) return null;
    }
    return UniqueRectangle('Type 5 UR for $d in $diag1, $diag2');
  }
}

class UniqueRectangle extends Technique {
  UniqueRectangle(String message) : super(message, 100);
}
