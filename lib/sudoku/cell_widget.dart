import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/cell.dart';
import '../models/game.dart';

class CellWidget extends StatelessWidget {
  const CellWidget(this.cell, {Key? key, required this.size}) : super(key: key);

  final Cell cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final isSelected = game.selectedCell == cell;
    final matchDigit = game.selectedCell?.digit;
    return GestureDetector(
      onTap: () {
        game.select(cell);
      },
      child: Container(
        width: size,
        height: size,
        // color: colors.background,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // indicator
            Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accent
                    : cell.digit > 0 && cell.digit == matchDigit
                        ? colors.indicatorDark
                        : cell.isClue
                            ? colors.indicatorLight
                            : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
            ),
            cell.digit > 0
                ? Opacity(
                    opacity: cell.isClue ? 0.7 : 1,
                    child: AppText(
                      cell.digit.toString().replaceAll('0', ''),
                      size: size * 0.5,
                      // weight: FontWeight.w300,
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: size * 0.17),
                    child: Wrap(
                      children: cell.candidates
                          .map(
                            (candidate) => Container(
                              alignment: Alignment.center,
                              width: size * 0.22,
                              child: AppText(
                                candidate.toString(),
                                size: size / 5,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
