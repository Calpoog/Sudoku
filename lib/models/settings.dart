import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  bool showMatchingNumbers = false;
  bool highlightRowColumn = false;
  bool indicateStartingHints = false;
  bool showRemainingCount = false;

  void load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = jsonDecode(prefs.getString('settings') ?? '');
    showMatchingNumbers = json['showMatchingNumbers'] ?? false;
    highlightRowColumn = json['highlightRowColumn'] ?? false;
    indicateStartingHints = json['indicateStartingHints'] ?? false;
    showRemainingCount = json['showRemainingCount'] ?? false;
    notifyListeners();
  }
}
