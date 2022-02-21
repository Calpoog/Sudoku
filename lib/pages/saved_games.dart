import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../common/text.dart';
import '../models/game.dart';
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
                        itemCount: count,
                        itemBuilder: (context, index) {
                          final game = snapshot.data![index];
                          return ListTile(
                            title: AppText(game.title),
                            trailing: AppText(DateFormat.MEd().format(game.lastPlayed!)),
                            onTap: () {
                              context.go('/sudoku/${game.id}');
                            },
                          );
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
