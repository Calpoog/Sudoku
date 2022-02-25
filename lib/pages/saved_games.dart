import 'dart:math';

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

const kSavedGameMaxTileWidth = 350.0;

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
          final games = snapshot.data!;
          final count = games.length;
          final screenWidth = MediaQuery.of(context).size.width;
          final crossAxisCount = (screenWidth / kSavedGameMaxTileWidth).floor();
          return ListView.builder(
              itemCount: (count / crossAxisCount).ceil(),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = index * crossAxisCount; i < min(count, crossAxisCount * (index + 1)); i++)
                      Container(
                        width: kSavedGameMaxTileWidth,
                        padding: const EdgeInsets.all(10.0),
                        child: SavedGameTile(game: games[i]),
                      ),
                  ],
                );
              });
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
              decoration: BoxDecoration(
                color: colors.indicatorDark,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              // constraints: const BoxConstraints(maxHeight: 300.0),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GridWidget(game.grid, isPreview: true),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AppText('LAST PLAYED', weight: FontWeight.bold),
                      AppText('TIME', weight: FontWeight.bold),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(DateFormat.MEd().format(game.lastPlayed!)),
                      AppText(game.timer.currentDuration.inSeconds.toString()),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
