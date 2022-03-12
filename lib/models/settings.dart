import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/saves.dart';

final settings = Settings();

class Settings extends ChangeNotifier {
  bool _showMatchingNumbers = false;
  set showMatchingNumbers(bool value) {
    _showMatchingNumbers = value;
    _save();
  }

  bool get showMatchingNumbers => _showMatchingNumbers;

  bool _highlightRowColumn = false;
  set highlightRowColumn(bool value) {
    _highlightRowColumn = value;
    _save();
  }

  bool get highlightRowColumn => _highlightRowColumn;

  bool _indicateStartingHints = false;
  set indicateStartingHints(bool value) {
    _indicateStartingHints = value;
    _save();
  }

  bool get indicateStartingHints => _indicateStartingHints;

  bool _showRemainingCount = false;
  set showRemainingCount(bool value) {
    _showRemainingCount = value;
    _save();
  }

  bool get showRemainingCount => _showRemainingCount;

  bool _clearPencilOnDigit = false;
  set clearPencilOnDigit(bool value) {
    _clearPencilOnDigit = value;
    _save();
  }

  bool get clearPencilOnDigit => _clearPencilOnDigit;

  _save() {
    ManageSaves.saveSettings(this);
    notifyListeners();
  }

  void load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = jsonDecode(prefs.getString('settings') ?? '{}');
    _showMatchingNumbers = json['showMatchingNumbers'] ?? false;
    _highlightRowColumn = json['highlightRowColumn'] ?? false;
    _indicateStartingHints = json['indicateStartingHints'] ?? false;
    _showRemainingCount = json['showRemainingCount'] ?? false;
    notifyListeners();
  }

  Map<String, dynamic> toJSON() {
    return {
      'showMatchingNumbers': _showMatchingNumbers,
      'highlightRowColumn': _highlightRowColumn,
      'indicateStartingHints': _indicateStartingHints,
      'showRemainingCount': _showRemainingCount,
    };
  }
}
