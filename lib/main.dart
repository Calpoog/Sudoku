import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'common/button.dart';
import 'common/colors.dart';
import 'common/spacing.dart';
import 'common/text.dart';
import 'models/box.dart';
import 'models/cell.dart';
import 'models/grid.dart';

import 'models/game.dart';
import 'sudoku/grid_widget.dart';

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
      outline: const Color.fromRGBO(231, 231, 231, 0.2),
      button: const Color.fromRGBO(74, 80, 95, 1),
      icon: const Color.fromRGBO(255, 255, 255, 0.5),
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

class Sudoku extends StatelessWidget {
  Sudoku({Key? key}) : super(key: key);

  final grid = Grid.fromString('004300209005009001070060043006002087190007400050083000600000105003508690042910300');

  @override
  Widget build(BuildContext context) {
    debugPrint(grid.toString());
    final colors = context.read<ThemeColors>();
    final spacing = relativeWidth(context, 0.046);
    final buttonSize = relativeWidth(context, 0.13);

    return ChangeNotifierProvider(
      create: (context) => SudokuGame(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 20.0),
          Container(
            color: colors.surface,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildDigitButtonRow(buttonSize, spacing, 0, 5),
                SizedBox(height: spacing),
                _buildDigitButtonRow(
                  buttonSize,
                  spacing,
                  5,
                  4,
                  Button(
                    size: buttonSize,
                    child: Icon(Icons.ac_unit, color: colors.icon),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(text: 'Restart', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
              SizedBox(width: spacing),
              Button(text: 'Check', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
              SizedBox(width: spacing),
              Button(text: 'Multi', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
              SizedBox(width: spacing),
              Button(text: 'Pencil', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
              SizedBox(width: spacing),
              Button(text: 'Undo', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDigitButtonRow(double buttonSize, double spacing, int start, int length, [Widget? extra]) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...List.generate(
        length,
        (index) => Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: DigitButton(
            digit: index + 1 + start,
            size: buttonSize,
          ),
        ),
      ),
      if (extra != null) extra,
    ]);
  }
}
