import 'dart:convert';
import 'dart:io';

import 'solver.dart';

void main(List<String> arguments) async {
  // processFile(arguments.first);

  // Hard I guess
  // Puzzle.fromString('.....6....59.....82....8....45........3........6..3.54...325..6..................');

  // XWing
  // Puzzle.fromString('2....7...7........1..................2974.5185....9...9........8.........7395.281');

  // Coloring with 2 of same color in unit
  // Puzzle.fromString('..7.836...397.68..82641975364.19.387.8.367....73.48.6.39.87..267649..1382.863.97.');
  // Puzzle.fromString('2...41..64..6.2.1..16.9...43..12964.142.6.59..695.4..158421637992.4.81656.19..482');

  // Coloring with opposite colors in unit
  // Puzzle.fromString('..85.21.335...12.8.21.3..5.56324.7.14821.753.179.53..2.3..2581.8.731..25215.843..');

  // Coloring with uncolored square seeing two colors
  // Puzzle.fromString('..463.5..6.54.1..337..5964.938.6.154457198362216345987.435.6.19.6.9.34.55.9.14.36');

  // YWings https://www.sudokuwiki.org/Y_Wing_Strategy
  // Puzzle.fromString('9..24.....5.69.231.2..5..9..9.7..32...29356.7.7...29...69.2..7351..79.622.7.86..9');

  // XYZWings https://www.sudokuwiki.org/XYZ_Wing
  // Puzzle.fromString('.92..175.5..2....8....3.2...75..496.2...6..75.697...3...8.9..2.7....3.899.38...4.');

  // Perfect Swordfish https://www.sudokuwiki.org/Sword_Fish_Strategy
  // Puzzle.fromString('52941.7.3..6..3..2..32......523...76637.5.2..19.62753.3...6942.2..83.6..96.7423.5');

  // Jellyfish https://www.sudokuwiki.org/Jelly_Fish_Strategy
  // Puzzle.fromString('..17538...5......77..89.1.....6.157.625478931.179.54......67..4.7.....1...63.97..');

  // Unique Rectangles Rule 1 https://www.sudokuwiki.org/Unique_Rectangles
  // Puzzle.fromString('..632481585.691.7...1785.....4.3768.38..62147.6741835....173..8...846.21..82597..');
  // Rule 2
  // Puzzle.fromString('42.9..386.6.2..7948.9.6.2517....3.259..1.26.32..5....8..4.2.5676827..439......812');
  // Rule 2b
  // Puzzle.fromString('.4186539..9..4..6..3.7924.1.28...94.519624..3.7.9.821.15..8.629.6..19.3.98.2.61..');
  // Rule 2c
  // Puzzle.fromString('8.9....5.53.8.7.......9.8..2946.813.78.9.1..4.15..4.98..2.8.....581.3.7..6....48.');
  // Rule 3
  // Puzzle.fromString('...5.347.5..8.4.6.4...96.52857..96.43246.759...6..5.37285.61.4...9..8..5.43952.86');
  // Rule 3b
  // Puzzle.fromString('419.2...6.6.1.9....3.465921.9.2.1.8...1.5.29..7.9.4.1...65.2.79.5.398.6292......8');
  // Rule 3b with pseudo triple
  // Puzzle.fromString('7529.8.4.3..21.....1....28..63.82..9.27.9.5.88..1...32271..98.4....213.7.3.874.2.');
  // Rule 4 with pseudo triple
  // Puzzle.fromString('300200640005040000000050900002000090050000006090000051400863000060007800000400302');

  // X Cycles: Nice Loops Rule 1 https://www.sudokuwiki.org/X_Cycles
  // Puzzle.fromString('.241..67..6..7.41.7..964.2.2465913871354872968796231544....976.35.71694.697.4..31');

  // X Cycles: Nice Loops Rule 2 https://www.sudokuwiki.org/X_Cycles_Part_2
  // Puzzle.fromString('8.4537....23614.856.5982.34...1.587.5..7.83.6.8.2.345.2..859..3.5.3712.8..84265.7');

  // X Cycles: Nice Loops Rule 3 https://www.sudokuwiki.org/X_Cycles_Part_2
  // Puzzle.fromString('.762..4...941.7.6.2..46...7.6.371...74.592.16...684.7.3.97.6..568.9.573.4578.36..');

  // 3D Medusa https://www.sudokuwiki.org/3D_Medusa
  // Rule 1
  // Puzzle.fromString('.9382456..856....22.6.75..8321769845...2583..578.4.29685..16723..7.8265...25.718.');
  // Rule 2 (and 5)
  // Puzzle.fromString('3...52...25.3...1...46.7523.932..8.557.....3.4.8.35.6...54.83...3.5.6.8484..23.56');
  // Rule 4
  // Puzzle.fromString('1...56..3.43.9....8...43..2.3.56.21.95.421.37.21.3....31798...5...31.97....67.3.1');
  // Rule 6
  // Puzzle.fromString('9867213453.4956..7..7.3.96..73.65..969..17..31..39.276...679.3..691437..731582694');

  // From "Sudoku: The Clean One"
  // "Medium"
  // Puzzle.fromString('.465..3..1..43.7.57....8...5.....8...87..6.5.96..8.14.85412.....2.86........5.218');
  // "Hard"
  // Puzzle.fromString('9..75..68.2...95.16.7.3.24.....6.45...5.2...3.....56.......312..1428..9.....7..3.');
  // "Extreme"
  // Puzzle.fromString('..5.....8...18...7.....412...9.....2.4.3..5..5.6..7.8.6...9...1.2...5....9.6..7..');

  // From sudokuoftheday.com
  // Fiendish
  // Puzzle.fromString('...14..53........9..5.9..2.8....2....3.4.7.9....9....2.4..6.7..3........56..14...');
  // Diabolical
  // Puzzle.fromString('3.......97.24...5...5.6....4...72.8....5.4....7.61...2....4.3...5...71.828......4');
  // Puzzle.fromString('5.24.6..9..721.....1...7...2.61...9.1.......8.5...82.1...8...3.....426..3..7.91.2');
  Puzzle.fromString('.4.1.36.......7..56...8.4..21...5..4.7..2..5.8..6...72..4.3...19..7.......89.4.2.')

    // Puzzle.fromString('.384.....2..9...38.6538.7......3.14.6.3.1...5.1..5...3..459362132...8..7.....738.')
    // Puzzle.fromString('700900420092000000003257900304780209970002000205193704009624100000070892027809046')
    // Puzzle.fromString('500070003010600080002009000060000900700000802008000010000900600030001070400020008')
    ..solve()
    ..display();

//   Puzzle.fromTestState('''
// +------------------+-----------------------+------------------+
// | 5    489  469    | 1248   7      248     | 124  2469 3      |
// | 39   1    3479   | 6      345    2345    | 2457 8    4579   |
// | 368  478  2      | 13458  13458  9       | 1457 456  14567  |
// +------------------+-----------------------+------------------+
// | 123  6    1345   | 234578 13458  234578  | 9    345  457    |
// | 7    459  13459  | 1345   134569 3456    | 8    3456 2      |
// | 239  2459 8      | 23457  34569  3457    | 3457 1    4567   |
// +------------------+-----------------------+------------------+
// | 128  2578 157    | 9      3458   34578   | 6    2345 145    |
// | 2689 3    569    | 458    4568   1       | 245  7    459    |
// | 4    579  15679  | 357    2      3567    | 135  359  8      |
// +------------------+-----------------------+------------------+
// ''')
//     ..solve()
//     ..display();
  // Puzzle.withDifficulty(min: 7000);
}

processFile(String filename) async {
  final file = File(filename);
  Stream<String> lines = file
      .openRead()
      .transform(utf8.decoder) // Decode bytes to UTF-8.
      .transform(const LineSplitter()); // Convert stream to individual lines.
  try {
    var count = 0;
    await for (var line in lines) {
      var puzzle = line.split(',').first;
      Puzzle.fromString(puzzle);
      print(count++);
    }
    print('File is now closed.');
  } catch (e) {
    print('Error: $e');
  }
}
