import "display_manager.dart";

class ClearTextManager {
  final DisplayManager displayManager;
  late List<String> clearTextList;
  late String currentClearText;

  ClearTextManager({required this.displayManager});

  void setClearTextList(List<String> newClearTextList) {
    clearTextList = newClearTextList;
  }

  void addClearText(String newClearText) {
    clearTextList.add(newClearText);
  }

  void removeClearText(String text) {
    clearTextList.remove(text);

    if (currentClearText == text) {
      currentClearText = clearTextList.isNotEmpty ? clearTextList.first : "";
    }
  }

  void setClearText(String newClearText) {
    currentClearText = newClearText;
  }

  void selectFromIndex(int index) {
    setClearText(clearTextList[index]);
  }
}
