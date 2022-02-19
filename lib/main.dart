import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'sudoku/constants.dart';
import 'common/button.dart';
import 'common/colors.dart';
import 'common/spacing.dart';
import 'common/text.dart';
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
      button: const Color.fromRGBO(39, 41, 47, 1),
      icon: const Color.fromRGBO(255, 255, 255, 0.5),
      indicatorDark: const Color.fromRGBO(14, 14, 15, 1),
      indicatorLight: const Color.fromRGBO(55, 57, 61, 1),
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
        home: const Scaffold(
          body: SafeArea(child: Sudoku()),
        ),
      ),
    );
  }
}

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SudokuGame(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final game = context.read<SudokuGame>();
          var shouldScroll = false;
          var preferredGridSize = constraints.maxWidth;
          var spacing = relativeWidth(context, 0.046).clamp(kMinSpacing, kMaxSpacing);
          var buttonSize = relativeWidth(context, 0.13).clamp(kMinButtonSize, kMaxButtonSize);
          var headerHeight = relativeWidth(context, 0.13).clamp(kMinHeaderHeight, kMaxHeaderHeight);

          // Scenario 1: best is everything at their max size fits
          var spaceRemaining = constraints.maxHeight - preferredGridSize - maxFixedHeight;
          if (spaceRemaining < 0) {
            // Scenario 2: try everything at their min to see if it fits
            final size = game.grid.size;
            preferredGridSize = kMinGridCellSize * size * size + (size - 1) * (kSubLineWidth * size + kMainLineWidth);
            spaceRemaining = constraints.maxHeight - preferredGridSize - minFixedHeight;

            if (spaceRemaining < 0) {
              // Scenario 3: everything at their min does not fit, so scroll I guess
              shouldScroll = true;
              spacing = kMinSpacing;
              buttonSize = kMinButtonSize;
              headerHeight = kMinHeaderHeight;
            } else {
              // Scenario 2 works: there's a happy medium between min and max sizes
              final factor = constraints.maxHeight / (minFixedHeight + preferredGridSize);

              // the factor may be limited on the grid due to width
              preferredGridSize = (preferredGridSize * factor).clamp(0, constraints.maxWidth);
              spacing = kMinSpacing * factor;
              buttonSize = kMinButtonSize * factor;
              headerHeight = kMinHeaderHeight * factor;
              spaceRemaining =
                  constraints.maxHeight - (headerHeight + spacing * 6 + buttonSize * 3.5 + preferredGridSize);
            }
          } else {
            // clamping due to width can mean there's additional space remaining to distribute
            spaceRemaining +=
                kMaxHeaderHeight - headerHeight + (kMaxSpacing - spacing) * 6 + (kMaxButtonSize - buttonSize) * 3.5;
          }
          final overflowSpacing = (spaceRemaining / 3).clamp(0, double.infinity).toDouble();
          final colors = context.read<ThemeColors>();
          final content =
              _buildGame(spacing, preferredGridSize, game, colors, headerHeight, buttonSize, overflowSpacing);

          return shouldScroll ? SingleChildScrollView(child: content) : content;
        },
      ),
    );
  }

  Column _buildGame(
    double spacing,
    double preferredGridSize,
    SudokuGame game,
    ThemeColors colors,
    double headerHeight,
    double buttonSize,
    double overflowSpacing,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SudokuHeader(
          height: headerHeight,
          contentWidth: preferredGridSize,
        ),
        SizedBox(height: overflowSpacing),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: preferredGridSize, maxHeight: preferredGridSize),
            child: GridWidget(game.grid),
          ),
        ),
        SizedBox(height: spacing + overflowSpacing.clamp(0, 100.0)),
        Container(
          color: colors.surface,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: spacing),
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
                  child: SvgPicture.asset('assets/icons/x.svg', width: buttonSize * 0.4),
                  onPressed: () => game.clearCell(),
                ),
              ),
            ],
          ),
        ),
        GameActions(buttonSize: buttonSize, spacing: spacing),
      ],
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

class SudokuHeader extends StatelessWidget {
  const SudokuHeader({
    Key? key,
    required this.contentWidth,
    required this.height,
  }) : super(key: key);

  final double height;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: DefaultTextStyle(
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        child: Container(
          width: contentWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SvgPicture.asset('assets/icons/back.svg', semanticsLabel: 'Back to menu'),
              Clock(size: height * 0.3),
            ],
          ),
        ),
      ),
    );
  }
}

class GameActions extends StatelessWidget {
  const GameActions({
    Key? key,
    required this.buttonSize,
    required this.spacing,
  }) : super(key: key);

  final double buttonSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: IconTheme(
        data: IconThemeData(size: buttonSize * 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
                text: 'Restart',
                size: buttonSize,
                child: SvgPicture.asset(
                  'assets/icons/board.svg',
                  width: buttonSize * 0.45,
                )),
            SizedBox(width: spacing),
            Button(
                text: 'Check',
                size: buttonSize,
                child: SvgPicture.asset(
                  'assets/icons/check.svg',
                  width: buttonSize * 0.45,
                )),
            SizedBox(width: spacing),
            Button(text: 'Multi', size: buttonSize, child: Icon(Icons.undo, color: colors.icon)),
            SizedBox(width: spacing),
            Button(
              text: 'Pencil',
              size: buttonSize,
              child: SvgPicture.asset(
                'assets/icons/pencil.svg',
                width: buttonSize * 0.57,
              ),
              isActive: game.isPenciling,
              onPressed: () => game.togglePencil(),
            ),
            SizedBox(width: spacing),
            Button(
              text: 'Undo',
              size: buttonSize,
              child: SvgPicture.asset(
                'assets/icons/undo.svg',
                width: buttonSize * 0.45,
              ),
              onPressed: () => game.undo(),
            ),
          ],
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({Key? key, required this.size}) : super(key: key);

  final double size;

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late final Timer timer;
  int seconds = 0;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hours = (seconds / 3600).floor();
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    final time = [
      if (hours > 0) hours,
      if (mins > 0) mins,
      secs,
    ];
    return AppText('${time.join(':')}s', size: widget.size);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
