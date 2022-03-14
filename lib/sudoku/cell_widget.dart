import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/cell.dart';
import '../models/game.dart';
import '../models/settings.dart';
import '../pages/sudoku/sudoku_page.dart';

class CellWidget extends StatelessWidget {
  const CellWidget(this.cell, {Key? key, required this.size, this.isPreview = false}) : super(key: key);

  final Cell cell;
  final double size;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final contents = AnimatedCell(size: size, cell: cell, digit: cell.digit);

    if (isPreview) return contents;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        game.select(cell);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        game.clearCell(cell: cell);
      },
      // onDoubleTap: () => game.clearCell(cell),
      child: contents,
    );
  }
}

class AnimatedCell extends StatefulWidget {
  const AnimatedCell({
    Key? key,
    required this.size,
    required this.digit,
    required this.cell,
  }) : super(key: key);

  final double size;
  final int digit;
  final Cell cell;

  @override
  State<AnimatedCell> createState() => _AnimatedCellState();
}

const kCompleteAnimationFactor = 0.8;

class _AnimatedCellState extends State<AnimatedCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late SudokuGame game;
  late final random = Random();
  int? clearingDigit;
  double horizontalSpeed = 0;
  bool isDone = false;

  @override
  void didUpdateWidget(covariant AnimatedCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit > 0 && widget.digit == 0) {
      clearingDigit = oldWidget.digit;
      _startClearAnimation();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, upperBound: 300, lowerBound: -1000);
    _controller.addStatusListener(_clearFinished);
    completeNotifier.addListener(_completeListener);
  }

  void _completeListener() {
    // final start = max((widget.cell.col - 4).abs(), (widget.cell.row - 4).abs()) * 150;
    final start = (sqrt(pow(widget.cell.col - 4, 2) + pow(widget.cell.row - 4, 2)) * 150).toInt();

    Future.delayed(Duration(milliseconds: (start * kCompleteAnimationFactor).toInt()), () {
      setState(() {
        isDone = true;
      });
    });

    Future.delayed(Duration(milliseconds: ((start + 500) * kCompleteAnimationFactor).toInt()), () {
      setState(() {
        isDone = false;
      });
    });
  }

  void _startClearAnimation() {
    horizontalSpeed = Random().nextDouble() * 0.2 - 0.1;
    _controller.animateWith(GravitySimulation(
      300.0, // acceleration, pixels per second per second
      0.0, // starting position, pixels
      300.0, // ending position, pixels
      -100, // starting velocity, pixels per second
    ));
  }

  void _clearFinished(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        clearingDigit = null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    completeNotifier.removeListener(_completeListener);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final cell = widget.cell;
    final isSelected = game.selectedCell == cell;
    final matchDigit = game.selectedCell?.digit ?? 0;
    final isMatch = matchDigit > 0 && (cell.digit == matchDigit || cell.candidates.contains(matchDigit));
    final markedInvalid = cell.markedInvalid && cell.digit > 0;
    final indicatorColor = isSelected
        ? colors.accent
        : isMatch && settings.showMatchingNumbers
            ? colors.indicatorDark
            : cell.isClue && settings.indicateStartingHints
                ? colors.indicatorLight.withOpacity(0.5)
                : Colors.transparent;
    final hasIndicator = indicatorColor != Colors.transparent || markedInvalid;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(width: widget.size, height: widget.size),
        // indicator
        AnimatedContainer(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          width: widget.size * (hasIndicator ? 0.8 : 0.4),
          height: widget.size * (hasIndicator ? 0.8 : 0.4),
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.all(Radius.circular(widget.size * 0.2)),
            border: markedInvalid ? Border.all(color: colors.error, width: 2) : null,
          ),
        ),
        AnimatedContainer(
          curve: isDone ? Curves.easeIn : Curves.easeOut,
          duration: Duration(milliseconds: (300 * kCompleteAnimationFactor).toInt()),
          width: widget.size * (isDone ? 0.8 : 0.6),
          height: widget.size * (isDone ? 0.8 : 0.6),
          decoration: BoxDecoration(
            color: isDone ? colors.accent : Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(widget.size * 0.2)),
          ),
        ),
        cell.digit > 0
            ? Opacity(
                opacity: widget.cell.isClue ? 0.7 : 1,
                child: AnimatedScale(
                  curve: isDone ? Curves.easeIn : Curves.easeOut,
                  duration: Duration(milliseconds: (400 * kCompleteAnimationFactor).toInt()),
                  scale: isDone ? 1.3 : 1,
                  child: AppText(
                    cell.digit.toString().replaceAll('0', ''),
                    size: widget.size * 0.5,
                    weight: FontWeight.w300,
                  ),
                ),
              )
            : Container(
                alignment: Alignment.center,
                width: widget.size * 0.66,
                child: Wrap(
                  children: widget.cell.candidates
                      .map(
                        (candidate) => Container(
                          alignment: Alignment.center,
                          width: widget.size * 0.22,
                          child: AppText(
                            candidate.toString(),
                            size: widget.size / 5,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
        if (clearingDigit != null)
          Positioned(
            child: AnimatedBuilder(
              animation: _controller,
              child: AppText(
                clearingDigit.toString(),
                size: widget.size * 0.5,
                weight: FontWeight.w300,
              ),
              builder: (context, child) {
                final elapsed = (_controller.lastElapsedDuration ?? Duration.zero).inMilliseconds;
                return Opacity(
                  opacity: 1 - max(0, _controller.value / 300),
                  child: Transform.translate(
                    offset: Offset(
                      elapsed * horizontalSpeed,
                      _controller.value,
                    ),
                    child: Transform.rotate(angle: elapsed * 0.01, child: child!),
                  ),
                );
              },
            ),
          ),
        // Positioned(child: child)
      ],
    );
  }
}
