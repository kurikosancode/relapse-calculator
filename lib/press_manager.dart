import 'package:flutter/material.dart';
import 'config.dart';
import "display_manager.dart";
import 'mode_manager.dart';
import 'clear_text_manager.dart';
import 'music_manager.dart';
import 'lyrics_manager.dart';
import 'press_setting.dart';
import 'math_evaluator.dart';

class PressManager {
  final DisplayManager displayManager;
  final ModeManager modeManager;
  final ClearTextManager clearTextManager;
  final MusicManager musicManager;
  final LyricsManager lyricsManager;
  final PressSetting pressSetting;
  final MathEvaluator mathEvaluator;

  late Map<String, Function> normalActionMap;
  late Map<String, Function> lyricsActionMap;
  late Set<String> characterAppendSet;

  final Color textColorForClear;
  final Color defaultColor;

  PressManager(
      {required this.displayManager,
      required this.modeManager,
      required this.clearTextManager,
      required this.musicManager,
      required this.lyricsManager,
      required this.pressSetting,
      required this.mathEvaluator,
      this.textColorForClear = Colors.red,
      this.defaultColor = Colors.black});

  void initialize() {
    lyricsActionMap = {
      "C": _handleClearText,
      "=": _handleEqualsText,
      "(": () => {pressSetting.showClearSettings(_clearFunction)},
      ")": () => {pressSetting.showSongSettings(_clearFunction)},
      "%": _handlePercentageText,
    };

    normalActionMap = {
      "C": () => _clearFunction(),
      "=": () {
        String expr = displayManager.currentDisplay;

        try {
          displayManager.setDisplay(mathEvaluator.evaluateAndFormat(expr));
        } catch (_) {
          displayManager.setDisplay(errorMessage);
        }
      }
    };

    characterAppendSet = {"%", ".", "+", "-", "*", "/"};
  }

  void getPressAction(String char) {
    if (modeManager.normalMode) {
      _normalPressAction(char);
    } else {
      _lyricsPressAction(char);
    }
  }

  void _normalPressAction(String char) {
    if (displayManager.currentDisplay == errorMessage) {
      displayManager.currentDisplay = "0";
    }
    if (normalActionMap.containsKey(char)) {
      normalActionMap[char]!();
      return;
    }

    if (_isOperator(char)) {
      _handleOperator(char);
      return;
    }

    if (char == ".") {
      _handleDot();
      return;
    }

    if (char == "%") {
      _handlePercent();
      return;
    }

    _handleNumber(char);
  }

  void _handleNumber(String char) {
    if (displayManager.currentDisplay == "0") {
      displayManager.setDisplay(char);
    } else {
      displayManager.appendDisplay(char);
    }
  }

  bool _isOperator(String c) {
    return ["+", "-", "*", "/"].contains(c);
  }

  void _handleOperator(String op) {
    String text = displayManager.currentDisplay;

    if (text == "0" && op != "-") return;

    if (_isOperator(text[text.length - 1])) {
      displayManager.setDisplay(text.substring(0, text.length - 1) + op);
      return;
    }

    displayManager.appendDisplay(op);
  }

  void _handleDot() {
    String text = displayManager.currentDisplay;

    int lastOp = text.lastIndexOf(RegExp(r"[+\-*/]"));
    String currentNum = text.substring(lastOp + 1);

    if (currentNum.contains(".")) return;

    displayManager.appendDisplay(".");
  }

  void _handlePercent() {
    String text = displayManager.currentDisplay;

    try {
      double val = double.parse(text);
      val = val / 100.0;
      displayManager.setDisplay(val.toString());
    } catch (_) {}
  }

  void _clearFunction() {
    displayManager.setColor(defaultColor);
    displayManager.setDisplay("0");
    musicManager.stopSong();
  }

  void _lyricsPressAction(String characterPressed) {
    if (lyricsActionMap.containsKey(characterPressed)) {
      lyricsActionMap[characterPressed]!();
    } else {
      _appendText(characterPressed);
    }
  }

  void _appendText(String characterPressed) {
    if (displayManager.currentDisplay == errorMessage) {
      displayManager.setDisplay(characterPressed);
    } else if (displayManager.currentDisplay == "0" &&
        !characterAppendSet.contains(characterPressed)) {
      displayManager.setDisplay(characterPressed);
    } else {
      displayManager.appendDisplay(characterPressed);
    }
  }

  void _handleClearText() {
    displayManager.setColor(textColorForClear);
    displayManager.setDisplay(clearTextManager.currentClearText);
  }

  void _handleEqualsText() {
    lyricsManager.resetLyricsTimings();
    lyricsManager.startLyrics();
  }

  void _handlePercentageText() {
    lyricsManager.resetLyricsTimings();
    _clearFunction();
  }
}
