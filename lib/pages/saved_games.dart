import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/colors.dart';
import '../common/text.dart';
import '../models/game.dart';
import '../sudoku/grid_widget.dart';
import '../utils/saves.dart';
import 'sudoku/sudoku.dart';

class SavedGames extends StatelessWidget {
  const SavedGames({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final savedGames = ManageSaves.loadGames();
    return FutureBuilder(
      future: savedGames,
      builder: (context, AsyncSnapshot<List<SudokuGame>> snapshot) {
        if (snapshot.hasData) {
          final count = snapshot.data!.length;
          return Column(
            children: [
              Expanded(
                child: count == 0
                    ? const AppText('No games')
                    : ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: count,
                        itemBuilder: (context, index) {
                          final game = snapshot.data![index];
                          return SavedGameTile(game: game);
                        }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                  onPressed: () {
                    final newGame = SudokuGame.fresh();
                    newGame.save();
                    context.go('/sudoku/${newGame.id}', extra: newGame);
                  },
                  child: const AppText('New game'),
                ),
              ),
            ],
          );
        } else {
          return const AppText('Loading games...');
        }
      },
    );
  }
}

class SavedGameTile extends StatelessWidget {
  const SavedGameTile({Key? key, required this.game}) : super(key: key);

  final SudokuGame game;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<ThemeColors>();
    return ChangeNotifierProvider.value(
        value: game,
        builder: (context, _) {
          return GestureDetector(
            onTap: () => context.go('/sudoku/${game.id}', extra: game),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: colors.indicatorDark,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              // constraints: const BoxConstraints(maxHeight: 300.0),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  GridWidget(game.grid, isPreview: true),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AppText('LAST PLAYED'),
                      AppText('TIME'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(DateFormat.MEd().format(game.lastPlayed!)),
                      const AppText('10'),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
