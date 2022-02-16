import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors(
      background: const Color.fromRGBO(40, 41, 45, 1),
      line: const Color.fromRGBO(48, 51, 58, 1),
      surface: const Color.fromRGBO(48, 51, 58, 1),
      text: const Color.fromRGBO(255, 255, 255, 1),
      accent: const Color.fromRGBO(177, 130, 58, 1),
    );
    return Provider.value(
      value: colors,
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: colors.background,
        ),
        home: SafeArea(
          child: Scaffold(body: Sudoku()),
        ),
      ),
    );
  }
}

const kMainLineWidth = 2.0;
const kSubLineWidth = 1.0;

class Cell extends StatelessWidget {
  const Cell(this.cell, {Key? key, required this.size}) : super(key: key);

  final C cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.5),
      child: Text(cell.digit.toString()),
    );
  }
}

class Box extends StatelessWidget {
  const Box({Key? key, required this.cells, required this.cellSize}) : super(key: key);

  final List<C> cells;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int x = 0; x < 3; x++)
          Row(
            children: [for (int y = x; y < x + 3; y++) Cell(cells[y], size: cellSize)],
          ),
      ],
    );
  }
}

class C {
  final int x;
  final int y;
  int digit;

  C(this.x, this.y, this.digit);
}

class B {
  final List<C> cells;

  B(this.cells);
}

class Board extends StatelessWidget {
  const Board(this.cells, {Key? key}) : super(key: key);

  final List<C> cells;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize =
                ((constraints.maxWidth - kMainLineWidth * 2 - kSubLineWidth * 6) / 9).floorToDouble();
            return Wrap(
              children: [],
            );
          },
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final double cellSize;
  final ThemeColors colors;

  BoardPainter(this.cellSize, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = 6 * kSubLineWidth + 2 * kMainLineWidth + 9 * cellSize;
    var paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = colors.line;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i <= 8; i++) {
        if (i % 3 == 0) continue;
        final x = i * (cellSize + 1) + (i / 3).floor();
        if (flip == 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, boardSize), paint);
        } else {
          canvas.drawLine(Offset(0, x), Offset(boardSize, x), paint);
        }
      }
    }

    paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = colors.accent;

    for (int flip = 0; flip <= 1; flip++) {
      for (int i = 1; i <= 2; i++) {
        final x = i * (cellSize * 3 + 3);
        if (flip == 0) {
          canvas.drawLine(Offset(x, 0), Offset(x, boardSize), paint);
        } else {
          canvas.drawLine(Offset(0, x), Offset(boardSize, x), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Sudoku extends StatelessWidget {
  Sudoku({Key? key}) : super(key: key);

  final cells = List.generate(81, (index) => C(index % 9, (index / 9).floor(), 2));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Board(cells),
      ],
    );
  }
}
