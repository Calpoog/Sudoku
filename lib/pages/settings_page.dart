import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/header.dart';
import '../common/text.dart';
import '../models/game.dart';
import '../models/settings.dart';
import '../sudoku/grid_widget.dart';
import 'sudoku/sudoku_page.dart';

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
  })
    ..move(2, 1);

  @override
  Widget build(BuildContext context) {
    final settings = context.read<Settings>();

    return ChangeNotifierProvider.value(
      value: game,
      child: Column(
        children: [
          const AppHeader(title: 'Settings'),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              padding: const EdgeInsets.all(10.0),
              child: LayoutBuilder(builder: (context, constraints) {
                debugPrint(constraints.maxHeight.toString());
                final buttonSize = constraints.maxHeight / 8.8;
                final width = 6.2 * buttonSize;
                return SizedBox(
                  width: width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GridWidget(game.grid),
                      SudokuControls(
                        showActions: false,
                        buttonSize: buttonSize * 0.8,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: AppText('Show matching numbers'),
                    onTap: () {
                      settings.showMatchingNumbers = !settings.showMatchingNumbers;
                    },
                  ),
                  ListTile(
                    title: AppText('Highlight selected row & column'),
                    onTap: () {
                      settings.highlightRowColumn = !settings.highlightRowColumn;
                    },
                  ),
                  ListTile(
                    title: AppText('Indicate starting clues'),
                    onTap: () {
                      settings.indicateStartingHints = !settings.indicateStartingHints;
                    },
                  ),
                  ListTile(
                    title: AppText('Show remaining number count'),
                    onTap: () {
                      settings.showRemainingCount = !settings.showRemainingCount;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
