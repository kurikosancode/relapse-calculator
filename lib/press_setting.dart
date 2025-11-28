import 'setting_window.dart';
import 'package:flutter/material.dart';
import 'lyrics_manager.dart';
import 'settings_manager.dart';
import 'display_manager.dart';
import 'music_manager.dart';
import 'text_input_button.dart';
import 'clear_text_manager.dart';
import 'constants.dart';
import 'utils.dart';

class PressSetting {
  final DisplayManager displayManager;
  final LyricsManager lyricsManager;
  final SettingsManager settingsManager;
  final MusicManager musicManager;
  final ClearTextManager clearTextManager;
  late final Map manifestMap;
  late final BuildContext context;

  final void Function(void Function()) setState;

  final TextEditingController _textEditingController = TextEditingController();

  PressSetting(
      {required this.displayManager,
      required this.lyricsManager,
      required this.settingsManager,
      required this.musicManager,
      required this.clearTextManager,
      required this.setState});

  void initialize(Map newManifestMap, BuildContext newContext) {
    context = newContext;
    manifestMap = newManifestMap;
  }

  void saveFunction() {
    clearTextManager.addClearText(_textEditingController.text);
    clearTextManager.setClearText(_textEditingController.text);
    settingsManager.saveSettings(
        "clearText", clearTextManager.currentClearText);
    settingsManager.saveSettings(
        "userClearTextList", clearTextManager.clearTextList);
  }

  void removeFunction(String text) {
    clearTextManager.removeClearText(text);
    settingsManager.saveSettings(
        "clearText", clearTextManager.currentClearText);
    settingsManager.saveSettings(
        "userClearTextList", clearTextManager.clearTextList);
  }

  void showSongSettings(Function clearFunction) {
    showSettings<Map>(
      context: context,
      setterFunction: (Map newLyrics) => {
        clearFunction(),
        setState(() {}),
        lyricsManager.setLyrics(newLyrics),
        settingsManager.saveMap("songLyrics", newLyrics),
        musicManager.loadCurrentSong(manifestMap, newLyrics["songName"])
      },
      formatFunction: (Map currentLyric) =>
          formatSongName(currentLyric["songName"]),
      currentList: lyricsManager.lyricsList,
    );
  }

  void showClearSettings(Function clearFunction) {
    showSettings<String>(
        context: context,
        setterFunction: (String newClearText) => {
              clearFunction(),
              setState(() {}),
              settingsManager.saveSettings("clearText", newClearText),
              clearTextManager.setClearText(newClearText),
            },
        formatFunction: (String currentLyric) => currentLyric,
        currentList: clearTextManager.clearTextList,
        bottomWidget: TextInputButton(
            textController: _textEditingController,
            submitFunction: saveFunction),
        removable: true,
        removeFunction: removeFunction);
  }
}
