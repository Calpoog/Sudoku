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
    final matchDigit = game.selectedCell?.digit ?? 0;
    final isMatch = matchDigit > 0 && (cell.digit == matchDigit || cell.candidates.contains(matchDigit));
    final indicatorColor = isSelected
        ? colors.accent
        : isMatch
            ? colors.indicatorDark
            : cell.isClue
                ? colors.indicatorLight
                : Colors.transparent;
    final hasIndicator = indicatorColor != Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => game.select(cell),
      onLongPress: () => game.clearCell(cell),
      onDoubleTap: () => game.clearCell(cell),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: size, height: size),
          // indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size * (hasIndicator ? 0.8 : 0.2),
            height: size * (hasIndicator ? 0.8 : 0.2),
            decoration: BoxDecoration(
              color: indicatorColor,
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
    );
  }
}
