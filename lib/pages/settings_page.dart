import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../common/colors.dart';
import '../common/header.dart';
import '../common/text.dart';
import '../models/game.dart';
import '../models/settings.dart';
import '../sudoku/grid_widget.dart';
import 'sudoku/sudoku_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: game),
          ChangeNotifierProvider.value(value: settings),
          Provider(create: (_) => SudokuEntryAnimation(vsync: this, isComplete: true)),
        ],
        builder: (context, child) {
          return Consumer<Settings>(builder: (context, settings, _) {
            return Column(
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const AppText('Show matching numbers'),
                            onTap: () {
                              settings.showMatchingNumbers = !settings.showMatchingNumbers;
                            },
                            trailing: SettingsCheckbox(isChecked: settings.showMatchingNumbers),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const AppText('Highlight selected row & column'),
                            onTap: () {
                              settings.highlightRowColumn = !settings.highlightRowColumn;
                            },
                            trailing: SettingsCheckbox(isChecked: settings.highlightRowColumn),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const AppText('Indicate starting clues'),
                            onTap: () {
                              settings.indicateStartingHints = !settings.indicateStartingHints;
                            },
                            trailing: SettingsCheckbox(isChecked: settings.indicateStartingHints),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const AppText('Show remaining number count'),
                            onTap: () {
                              settings.showRemainingCount = !settings.showRemainingCount;
                            },
                            trailing: SettingsCheckbox(isChecked: settings.showRemainingCount),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: const AppText('Clear pencil markup when filling cell'),
                            onTap: () {
                              settings.clearPencilOnDigit = !settings.clearPencilOnDigit;
                            },
                            trailing: SettingsCheckbox(isChecked: settings.clearPencilOnDigit),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }
}

class SettingsCheckbox extends StatelessWidget {
  const SettingsCheckbox({Key? key, this.isChecked = false}) : super(key: key);

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return Container(
      height: 30,
      width: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.text),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: isChecked ? SvgPicture.asset('assets/icons/check.svg', width: 16) : null,
    );
  }
}
