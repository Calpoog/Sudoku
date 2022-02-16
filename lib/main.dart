import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/colors.dart';
import 'package:sudoku/models/box.dart';
import 'package:sudoku/models/cell.dart';
import 'package:sudoku/models/grid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  // SystemChrome.restoreSystemUIOverlays();

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
          fontFamily: 'Rubik',
        ),
        home: Scaffold(
          body: SafeArea(child: Sudoku()),
        ),
      ),
    );
  }
}

const kMainLineWidth = 2.0;
const kSubLineWidth = 1.0;

class AppText extends StatelessWidget {
  const AppText(this.text, {Key? key, this.size, this.weight}) : super(key: key);

  final String text;
  final double? size;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context);
    return Text(
      text,
      style: TextStyle(
        color: context.read<ThemeColors>().text,
        fontSize: size ?? style.style.fontSize,
        fontWeight: weight ?? style.style.fontWeight,
      ),
    );
  }
}

class CellWidget extends StatelessWidget {
  const CellWidget(this.cell, {Key? key, required this.size}) : super(key: key);

  final Cell cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final isSelected = game.selectedCell == cell;
    return GestureDetector(
      onTap: () {
        game.select(cell);
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.background,
        ),
        child: AppText(
          cell.digit.toString().replaceAll('0', ''),
          size: size * 0.5,
        ),
      ),
    );
  }
}

class BoxWidget extends StatelessWidget {
  const BoxWidget({Key? key, required this.box, required this.cellSize}) : super(key: key);

  final Box box;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final size = cellSize * box.size + (box.size - 1) * kSubLineWidth;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.read<ThemeColors>().line,
      ),
      child: Stack(
        children: box.cells
            .map(
              (cell) => Positioned(
                left: (cell.col - box.col * box.size) * (cellSize + kSubLineWidth),
                top: (cell.row - box.row * box.size) * (cellSize + kSubLineWidth),
                child: CellWidget(cell, size: cellSize),
              ),
            )
            .toList(),
      ),
    );
  }
}

class GridWidget extends StatelessWidget {
  const GridWidget(this.grid, {Key? key}) : super(key: key);

  final Grid grid;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: colors.accent,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize =
                ((constraints.maxWidth - kMainLineWidth * 2 - kSubLineWidth * 6) / 9).floorToDouble();
            final double boxOffset = cellSize * grid.size + kSubLineWidth * (grid.size - 1) + kMainLineWidth;
            return SizedBox(
              width: boxOffset * grid.size - kMainLineWidth,
              height: boxOffset * grid.size - kMainLineWidth,
              child: Stack(
                children: grid.boxes
                    .map(
                      (box) => Positioned(
                        left: box.col * boxOffset,
                        top: box.row * boxOffset,
                        child: BoxWidget(box: box, cellSize: cellSize),
                      ),
                    )
                    .toList(),
              ),
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

class SudokuGame extends ChangeNotifier {
  Cell? selectedCell;

  void select(Cell cell) {
    selectedCell = cell;
    notifyListeners();
  }
}

class Sudoku extends StatelessWidget {
  Sudoku({Key? key}) : super(key: key);

  final grid = Grid.fromString('004300209005009001070060043006002087190007400050083000600000105003508690042910300');

  @override
  Widget build(BuildContext context) {
    debugPrint(grid.toString());
    return ChangeNotifierProvider(
      create: (context) => SudokuGame(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: DefaultTextStyle(
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  AppText('1:39s'),
                  Expanded(child: Center(child: AppText('Sudoku', size: 22))),
                  AppText('HARD'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          GridWidget(grid),
        ],
      ),
    );
  }
}
