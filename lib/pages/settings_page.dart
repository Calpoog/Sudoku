import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/text.dart';
import '../models/game.dart';
import '../sudoku/grid_widget.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final game = SudokuGame.fromJSON({
    'grid': {
      'cells':
          '0[1234]c4c301c20c900c500c900c10c700c600c4c300c600c20c8c7c1c9000c7c4000c500c8c3000c600000c10c500c3c50c8c6c900c4c2c9c10c300'
    },
    'lastPlayed': 1,
    'id': 'settings',
    'playTime': 243,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: Column(
            children: [
              GridWidget(game.grid),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: AppText('Show matching numbers'),
                        value: true,
                        onChanged: (_) {},
                      ),
                      ListTile(title: AppText('Highlight selected row & column')),
                      ListTile(title: AppText('Indicate starting clues')),
                      ListTile(title: AppText('Show remaining number count')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
