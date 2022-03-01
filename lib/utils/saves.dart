import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';
import '../models/settings.dart';

// Keys for storage/retrieval DO NOT CHANGE ONCE FINALIZED
const saveIdKey = 'SaveIDs';

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
  static Future<void> saveGame(SudokuGame gameState) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saves = prefs.getStringList(saveIdKey) ?? [];
    String game = json.encode(gameState.toJSON());
    final Set<String> newSaves = Set.from(saves)..add(gameState.id);
    unawaited(prefs.setStringList(saveIdKey, newSaves.toList()));
    unawaited(prefs.setString(gameState.id, game));
  }

  static Future<List<SudokuGame>> loadGames() async {
    // This function will indiscriminately load all games that have been saved
    // The list of SudokuGames were retrieved by their titles as keys (which
    //   was stored as a separate list in the shared preferences).
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saves = prefs.getStringList(saveIdKey) ?? [];
    return saves.map((id) {
      final String gameState = prefs.getString(id) ?? '';
      return SudokuGame.fromJSON(jsonDecode(gameState));
    }).toList();
  }

  static Future<SudokuGame> loadGame(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String gameState = prefs.getString(id) ?? '';
    return SudokuGame.fromJSON(jsonDecode(gameState));
  }

  static Future<void> saveSettings(Settings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    unawaited(prefs.setString('settings', jsonEncode(settings.toJSON())));
  }
}
