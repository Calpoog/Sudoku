import 'package:collection/collection.dart';

import 'technique.dart';
import '../candidates.dart';
import '../solver.dart';
import '../units.dart';

extension XFishExtension on Solution {
  Technique? xWings(List<Unit> primary, List<Unit> secondary) {
    final result = xFish(primary, secondary, 2);
    if (result == null) return null;
    return result == '' ? None() : XWing('Xwing $result');
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
            if (candidates(line.squares[j]).has(d)) {
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
              .where((s) => candidates(s).has(d) && !combo.contains(primary[isRow ? s.row : s.col])));
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
    return line.squares.foldIndexed<Candidates>(
        Candidates(0), (i, previous, s) => candidates(s).has(d) ? Candidates(previous.value | (1 << 8 - i)) : previous);
  }
}

class XWing extends Technique {
  XWing(String message) : super(message, 100);
}

class Swordfish extends Technique {
  Swordfish(String message) : super(message, 100);
}

class Jellyfish extends Technique {
  Jellyfish(String message) : super(message, 100);
}
