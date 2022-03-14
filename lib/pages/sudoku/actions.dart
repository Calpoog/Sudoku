import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../common/button.dart';
import '../../common/colors.dart';
import '../../common/modal.dart';
import '../../models/game.dart';

class GameActions extends StatelessWidget {
  const GameActions({
    Key? key,
    required this.buttonSize,
    this.onComplete,
  }) : super(key: key);

  final double buttonSize;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<SudokuGame>();
    final colors = context.read<ThemeColors>();
    final spacing = buttonSize * 0.2;

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
              ),
              onPressed: () {
                Modal(
                  message: "This will clear all your work but won't reset your time. Are you sure you want to restart?",
                  acceptText: 'Restart',
                  onSuccess: () => game.restart(),
                ).show(context);
              },
            ),
            SizedBox(width: spacing),
            Button(
              text: 'Check',
              size: buttonSize,
              child: SvgPicture.asset(
                'assets/icons/check.svg',
                width: buttonSize * 0.45,
              ),
              onPressed: () {
                Modal(
                  message:
                      'When you check and the board is incorrect, your score will be moved to a separate leaderboard.',
                  acceptText: 'Check',
                  onSuccess: () => game.check(),
                ).show(context);
              },
            ),
            SizedBox(width: spacing),
            Button(
              text: 'Multi',
              size: buttonSize,
              child: Icon(Icons.undo, color: colors.icon),
              onPressed: () {
                if (onComplete != null) onComplete!();
              },
            ),
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
