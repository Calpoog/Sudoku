import 'technique.dart';
import '../solver.dart';
import '../units.dart';

extension YWingsExtension on Solution {
  Technique? xyzWings() {
    return yWings(true);
  }

  Technique? yWings([bool useZ = false]) {
    final hinges = squares.where((s) => candidates(s).length == (useZ ? 3 : 2));
    final pincers = useZ ? squares.where((s) => candidates(s).length == 2) : hinges;

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
              final shared = candidates(pincer1).intersection(candidates(pincer2));
              if (shared.isSingle && (useZ || !candidates(hinge).hasAll(shared))) {
                var sees = pincer1.peers.where((s) => pincer2.peers.contains(s) && candidates(s).has(shared.digit));
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
        !candidates(hinge).equals(candidates(pincer)) &&
        (useZ ? candidates(hinge).hasAll(candidates(pincer)) : candidates(hinge).hasAny(candidates(pincer))) &&
        hinge.peers.contains(pincer);
  }
}

class YWing extends Technique {
  YWing(String message) : super(message, 100);
}

class XYZWing extends Technique {
  XYZWing(String message) : super(message, 100);
}
