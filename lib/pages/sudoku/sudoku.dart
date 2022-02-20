import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../common/button.dart';
import '../../common/colors.dart';
import '../../common/spacing.dart';
import '../../models/game.dart';
import '../../sudoku/constants.dart';
import '../../sudoku/grid_widget.dart';
import 'actions.dart';
import 'header.dart';

class Sudoku extends StatelessWidget {
  const Sudoku({Key? key}) : super(key: key);

  static const routeName = '/sudoku';

  @override
  Widget build(BuildContext context) {
    final game = ModalRoute.of(context)!.settings.arguments as SudokuGame;
    return ChangeNotifierProvider.value(
      value: game,
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