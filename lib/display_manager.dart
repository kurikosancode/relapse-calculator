import 'package:flutter/material.dart';

class DisplayManager {
  static String defaultDisplay = "0";

  bool isDisplayingLyrics = false;
  String currentDisplay = defaultDisplay;
  Color color = Colors.black;

  void clearDisplay() {
    currentDisplay = defaultDisplay;
    isDisplayingLyrics = false;
  }

  void setDisplay(String newDisplay) {
    currentDisplay = newDisplay;
  }

  void appendDisplay(String newDisplay) {
    currentDisplay += newDisplay;
  }

  void removeLastCharacter() {
    currentDisplay = currentDisplay.substring(0, currentDisplay.length - 1);
  }

  void setColor(Color newColor) {
    color = newColor;
  }
}
