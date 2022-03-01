import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/cell.dart';
import '../models/game.dart';
import '../models/settings.dart';

class CellWidget extends StatelessWidget {
  const CellWidget(this.cell, {Key? key, required this.size, this.isPreview = false}) : super(key: key);

  final Cell cell;
  final double size;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final isSelected = game.selectedCell == cell;
    final matchDigit = game.selectedCell?.digit ?? 0;
    final isMatch = matchDigit > 0 && (cell.digit == matchDigit || cell.candidates.contains(matchDigit));
    final indicatorColor = isSelected
        ? colors.accent
        : isMatch && settings.showMatchingNumbers
            ? colors.indicatorDark
            : cell.isClue && settings.indicateStartingHints
                ? colors.indicatorLight.withOpacity(0.5)
                : Colors.transparent;
    final hasIndicator = indicatorColor != Colors.transparent;
    final contents = _buildContents(hasIndicator, indicatorColor);

    if (isPreview) return contents;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        game.select(cell);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        game.clearCell(cell);
      },
      // onDoubleTap: () => game.clearCell(cell),
      child: contents,
    );
  }

  Stack _buildContents(bool hasIndicator, Color indicatorColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(width: size, height: size),
        // indicator
        AnimatedContainer(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
          width: size * (hasIndicator ? 0.8 : 0.4),
          height: size * (hasIndicator ? 0.8 : 0.4),
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
                  weight: FontWeight.w300,
                ),
              )
            : Container(
                alignment: Alignment.center,
                width: size * 0.66,
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
        // Positioned(child: child)
      ],
    );
  }
}
