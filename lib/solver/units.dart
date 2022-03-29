import 'package:collection/collection.dart';

class Square {
  final int index;
  final int row;
  final int col;
  final int box;
  final List<Square> peers = [];
  final List<Unit> units = [];
  final bool isClue;
  late final List<bool> sees;

  Square({required this.col, required this.row, required this.box, required this.index, this.isClue = false}) {
    sees = List.generate(81, (i) {
      final row = (i / 9).floor();
      final col = i % 9;
      final box = (row / 3).floor() * 3 + (col / 3).floor();
      return row == this.row || col == this.col || box == this.box;
    });
  }

  List<bool> seesUnion(Square other) {
    return sees.mapIndexed((i, s) => sees[i] && other.sees[i]).toList();
  }

  isPeer(Square other) {
    return row == other.row || col == other.col || box == other.box;
  }

  @override
  String toString() {
    return String.fromCharCode(row + 65) + (col + 1).toString();
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
