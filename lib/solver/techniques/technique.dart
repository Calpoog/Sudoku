abstract class Technique {
  final String message;
  final int score;

  Technique(this.message, this.score);
}

class None extends Technique {
  None() : super('', 0);
}
