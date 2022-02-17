import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';

// Keys for storage/retrieval DO NOT CHANGE ONCE FINALIZED
String saveTitlesKey = 'SaveTitles';
class ManageSaves {
  // This currently assumes gameState will be a string and saves will have names
  // We can change that at any time, and have a serialization function once
  //   we know exactly what we want to save.
  // Data looks like a list of very long strings (presumably the grid state,
  //   all its cells, and the special rules.
  // In the future, I can make it so that we can pass in N number of objects that
  //   need to be saved, there's no need to limit it to a String and put the
  //   burden of serialization on the game logic - however I just don't know which
  //   fields we'll want to save here yet, so I have a string for now.
  static Future<void> saveGame(String gameState, String saveName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saves = prefs.getStringList(saveTitlesKey) ?? [];
    saves.add(saveName);
    unawaited(prefs.setStringList(saveTitlesKey, saves));
    unawaited(prefs.setString(saveName, gameState));

  }

  static Future<List<SudokuGame>> loadGames() async{
    // This function will indiscriminately load all games that have been saved
    // The list of SudokuGames were retrieved by their titles as keys (which
    //   was stored as a separate list in the shared preferences).
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saves = prefs.getStringList(saveTitlesKey) ?? [];
    final List<SudokuGame> gameStates = [];
    if(saves.isNotEmpty){
      for(int i = 0; i < saves.length; i++){
        final String gameTitle = saves[i];
        final String gameState = prefs.getString(gameTitle) ?? '';
        final SudokuGame game = deserializeGame(gameState);
        gameStates.add(game);
      }
    }
    return gameStates;
  }

  static SudokuGame deserializeGame(String gameState) {
    // We gotta figure out our syntax for serialization/deserialization and put
    //   that here
    return SudokuGame();
  }

  static String serializeGame(SudokuGame game){
    // Doing the serialization in the toString isn't necessarily recommended,
    //   because we don't wanna save useless shit like white space for formatting
    //   but until we decide the structure of a save, I'm leaving this default
    //   toString lol
    return game.toString();
  }
}