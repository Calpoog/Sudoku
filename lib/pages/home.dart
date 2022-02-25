import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/game.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText('SIMPLY', size: 52, weight: FontWeight.bold),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Baseline(
                    baseline: 30,
                    baselineType: TextBaseline.alphabetic,
                    child: AppText('SUDOKU', size: 52, weight: FontWeight.bold),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: colors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                _buildItem(context, 'board', 'NEW GAME', () {
                  final newGame = SudokuGame.fresh();
                  newGame.save();
                  context.go('/sudoku/${newGame.id}', extra: newGame);
                }),
                _buildItem(
                  context,
                  'saved-games',
                  'SAVED GAMES',
                  () => context.go('/games'),
                ),
                _buildItem(context, 'multiplayer', 'MULTIPLAYER'),
                _buildItem(context, 'maker', 'MAKER'),
                _buildItem(
                  context,
                  'settings',
                  'SETTINGS',
                  () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String icon, String text, [VoidCallback? onPressed]) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 20.0, 20.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 30.0),
              child: SvgPicture.asset('assets/icons/$icon.svg'),
            ),
            AppText(text, size: 20),
          ],
        ),
      ),
    );
  }
}
