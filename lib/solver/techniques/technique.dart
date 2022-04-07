abstract class Technique {
  final String message;
  final int difficulty;
  final int reuse;

  Technique(this.message, this.difficulty, this.reuse);

  @override
  String toString() {
    return runtimeType.toString();
  }
}

class NakedSingle extends Technique {
  NakedSingle(String message) : super(message, 50, 50);
}

class HiddenSingle extends Technique {
  HiddenSingle(String message) : super(message, 50, 50);
}

class None extends Technique {
  None() : super('', 0, 0);
}
