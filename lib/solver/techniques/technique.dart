abstract class Technique {
  final String message;
  final int score;

  Technique(this.message, this.score);

  @override
  String toString() {
    return runtimeType.toString();
  }
}

class None extends Technique {
  None() : super('', 0);
}
