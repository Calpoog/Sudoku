import 'solver.dart';
import 'units.dart';

typedef CandidateState = Map<Square, Candidates>;

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
