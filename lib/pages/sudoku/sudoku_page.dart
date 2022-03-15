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

final completeNotifier = CompleteNotifier();

class CompleteNotifier extends ChangeNotifier {
  CompleteNotifier();

  void complete() {
    notifyListeners();
  }
}

class SudokuEntryAnimation {
  final AnimationController controller;

  SudokuEntryAnimation({required TickerProvider vsync, bool isComplete = false})
      : controller = AnimationController(vsync: vsync, duration: const Duration(seconds: 2)) {
    if (isComplete) controller.forward(from: 1.0);
  }
}

class SudokuPage extends StatefulWidget {
  const SudokuPage({Key? key, this.id, this.game}) : super(key: key);

  final String? id;
  final SudokuGame? game;

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _focus = FocusNode();
  late Future<SudokuGame> _future;
  late final _entry = SudokuEntryAnimation(vsync: this);
  late var animation = CurvedAnimation(
    parent: _entry.controller,
    curve: const Interval(0, 0.5, curve: Curves.easeInCubic),
  );

  @override
  void initState() {
    super.initState();
    _fetch();
    _entry.controller.forward();
    _future.then((game) {
      game.save();
      game.timer.start();
    });

    WidgetsBinding.instance!.addObserver(this);
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
    } else if (widget.id == null) {
      _future = SudokuGame.create(25);
    } else {
      _future = ManageSaves.loadGame(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<SudokuGame> snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final game = snapshot.data!;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: game),
            Provider.value(value: _entry),
          ],
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
                  animation: animation,
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
                            offset: Offset(0, 50 * (1 - animation.value)),
                            child: Opacity(
                              opacity: _entry.controller.status != AnimationStatus.forward ? 1 : animation.value,
                              child: child,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Expanded(
                          child: SudokuControls(
                            onComplete: () {
                              completeNotifier.complete();
                              game
                                ..stopTimer()
                                ..save();
                              Future.delayed(
                                const Duration(milliseconds: 600),
                                () => _entry.controller.reverse(),
                              );
                            },
                          ),
                        ),
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _future.then((game) {
        game.timer.start();
      });
    } else {
      _save();
    }
  }

  _save() {
    _future.then((game) {
      game.timer.stop();
      game.save();
    });
  }

  @override
  void dispose() {
    _save();
    _focus.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}

class SudokuControls extends StatelessWidget {
  const SudokuControls({
    Key? key,
    this.showActions = true,
    this.buttonSize,
    this.onComplete,
  }) : super(key: key);

  final bool showActions;
  final double? buttonSize;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();

    return LayoutBuilder(builder: (context, constraints) {
      final buttonSize =
          this.buttonSize ?? min(kMaxButtonSize, min(constraints.maxHeight / 4.7, constraints.maxWidth / 6.2));
      final spacing = buttonSize * 0.2;
      final child = Column(
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
                    index: 8,
                    size: buttonSize,
                    child: SvgPicture.asset('assets/icons/x.svg', width: buttonSize * 0.4),
                    onPressed: () => context.read<SudokuGame>().clearCell(),
                  ),
                ),
              ],
            ),
          ),
          if (showActions)
            GameActions(
              buttonSize: buttonSize,
              onComplete: onComplete,
            ),
        ],
      );

      final opacity = CurvedAnimation(
        parent: context.read<SudokuEntryAnimation>().controller,
        curve: const Interval(0.4, 0.60, curve: Curves.ease),
      );

      return AnimatedBuilder(
        animation: opacity,
        builder: (context, child) => Opacity(
          opacity: opacity.value,
          child: child,
        ),
        child: child,
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
