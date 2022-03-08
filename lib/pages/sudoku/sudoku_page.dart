import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../common/button.dart';
import '../../common/colors.dart';
import '../../common/header.dart';
import '../../models/game.dart';
import '../../sudoku/constants.dart';
import '../../sudoku/grid_widget.dart';
import '../../utils/saves.dart';
import 'actions.dart';
import 'clock.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({Key? key, required this.id, this.game}) : super(key: key);

  final String id;
  final SudokuGame? game;

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late Future<SudokuGame> _future;
  late final AnimationController _entryController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _fetch();
    _entryController.forward();
    _future.then((game) {
      game.timer.start();
    });
  }

  @override
  void didUpdateWidget(covariant SudokuPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // refresh cached data
    if (oldWidget.id != widget.id) _fetch();
  }

  void _fetch() {
    if (widget.game != null) {
      _future = Future.value(widget.game);
    } else {
      _future = ManageSaves.loadGame(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();

    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<SudokuGame> snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final game = snapshot.data!;
        return ChangeNotifierProvider.value(
          value: game,
          child: KeyboardListener(
            autofocus: true,
            focusNode: _focus,
            onKeyEvent: (event) {
              if (event is! KeyDownEvent) return;
              if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
                game.up();
              } else if (event.logicalKey == LogicalKeyboardKey.keyS ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                game.down();
              } else if (event.logicalKey == LogicalKeyboardKey.keyA ||
                  event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                game.left();
              } else if (event.logicalKey == LogicalKeyboardKey.keyD ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight) {
                game.right();
              } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
                game.togglePencil();
              } else if (int.tryParse(event.character ?? '') != null) {
                game.activate(int.parse(event.character!));
              } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
                  event.logicalKey == LogicalKeyboardKey.delete) {
                game.clearCell();
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final game = context.read<SudokuGame>();

                return AnimatedBuilder(
                  animation: _animation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: constraints.maxWidth),
                    child: GridWidget(game.grid),
                  ),
                  builder: (context, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppHeader(
                          title: 'Sudoku',
                          trailing: Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: Clock(size: 14),
                          ),
                        ),
                        Center(
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - _animation.value)),
                            child: Opacity(opacity: _animation.value, child: child),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        const Expanded(child: SudokuControls())
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _future.then((game) => game.timer.stop());
    _focus.dispose();
    super.dispose();
  }
}

class SudokuControls extends StatelessWidget {
  const SudokuControls({Key? key, this.showActions = true, this.buttonSize}) : super(key: key);

  final bool showActions;
  final double? buttonSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();

    return LayoutBuilder(builder: (context, constraints) {
      final buttonSize =
          this.buttonSize ?? min(kMaxButtonSize, min(constraints.maxHeight / 4.7, constraints.maxWidth / 6.2));
      final spacing = buttonSize * 0.2;
      return Column(
        children: [
          Container(
            color: colors.surface,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: spacing),
            child: Column(
              children: [
                _DigitRow(buttonSize: buttonSize, start: 0, length: 5),
                SizedBox(height: spacing),
                _DigitRow(
                  buttonSize: buttonSize,
                  start: 5,
                  length: 4,
                  extra: Button(
                    size: buttonSize,
                    child: SvgPicture.asset('assets/icons/x.svg', width: buttonSize * 0.4),
                    onPressed: () => context.read<SudokuGame>().clearCell(),
                  ),
                ),
              ],
            ),
          ),
          if (showActions) GameActions(buttonSize: buttonSize),
        ],
      );
    });
  }
}

class _DigitRow extends StatelessWidget {
  const _DigitRow({
    Key? key,
    required this.buttonSize,
    required this.start,
    required this.length,
    this.extra,
  }) : super(key: key);

  final double buttonSize;
  final int start;
  final int length;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...List.generate(
        length,
        (index) => Padding(
          padding: EdgeInsets.only(right: index < 4 ? buttonSize * 0.2 : 0),
          child: DigitButton(
            digit: index + 1 + start,
            size: buttonSize,
          ),
        ),
      ),
      if (extra != null) extra!,
    ]);
  }
}
