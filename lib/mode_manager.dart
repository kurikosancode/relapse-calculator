class ModeManager {
  bool normalMode = false;

  void toggleMode() {
    normalMode = !normalMode;
  }

  void setMode(bool newMode) {
    normalMode = newMode;
  }
}
