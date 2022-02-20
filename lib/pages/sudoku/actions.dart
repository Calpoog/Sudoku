import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../common/button.dart';
import '../../common/colors.dart';
import '../../models/game.dart';

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
              ),
              onPressed: () {},
            ),
            SizedBox(width: spacing),
            Button(
              text: 'Check',
              size: buttonSize,
              child: SvgPicture.asset(
                'assets/icons/check.svg',
                width: buttonSize * 0.45,
              ),
              onPressed: () {},
            ),
            SizedBox(width: spacing),
            Button(
              text: 'Multi',
              size: buttonSize,
              child: Icon(Icons.undo, color: colors.icon),
              onPressed: () {},
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
