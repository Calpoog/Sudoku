abstract class Technique {
  final String message;
  final int score;

  Technique(this.message, this.score);
}

class None extends Technique {
  None() : super('', 0);
}

class PointingPair extends Technique {
  PointingPair(String message) : super(message, 100);
}

class BoxLineIntersection extends Technique {
  BoxLineIntersection(String message) : super(message, 100);
}

class NakedSubset extends Technique {
  NakedSubset(String message) : super(message, 100);
}

class HiddenSubset extends Technique {
  HiddenSubset(String message) : super(message, 100);
}

class XWing extends Technique {
  XWing(String message) : super(message, 100);
}

class YWing extends Technique {
  YWing(String message) : super(message, 100);
}

class SinglesChain extends Technique {
  SinglesChain(String message) : super(message, 100);
}
