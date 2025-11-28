import 'package:flutter/scheduler.dart';
import 'utils.dart';

import 'music_manager.dart';
import 'display_manager.dart';

class LyricsManager {
  late Ticker ticker;

  final MusicManager musicManager;
  final DisplayManager displayManager;

  final void Function(void Function()) setState;

  bool initializedLyrics = false;

  double elapsedTime = 0.0;
  int currentLyricIndex = 0;

  late List<Map<dynamic, dynamic>> lyricsList;
  late Map<dynamic, dynamic> currentLyrics;

  LyricsManager({
    required this.musicManager,
    required this.displayManager,
    required this.setState,
  }) {
    ticker = Ticker(_onTick);
  }

  void dispose() {
    ticker.dispose();
  }

  void setLyricsList(List<Map<dynamic, dynamic>> newLyricsList) {
    lyricsList = newLyricsList;
  }

  void setLyrics(Map<dynamic, dynamic> newLyrics) {
    currentLyrics = newLyrics;
  }

  void selectFromIndex(int index) {
    setLyrics(lyricsList[index]);
  }

  void _onTick(Duration duration) {
    elapsedTime = duration.inMilliseconds / 1000;
    if (displayManager.isDisplayingLyrics) {
      _displayLyrics();
    }
  }

  Future<void> startLyrics() async {
    await musicManager.playSong();
    ticker.start();
    displayManager.isDisplayingLyrics = true;
    displayManager.setDisplay("");
    _displayLyrics();
  }

  void _displayLyrics() {
    if (initializedLyrics) {
      return;
    }

    List<dynamic> lyrics = currentLyrics["lyrics"];

    if (currentLyricIndex >= lyrics.length) {
      // print(currentLyricIndex);
      ticker.stop();
      return;
    }

    var line = lyrics[currentLyricIndex];
    double startTime = line['startTime'];

    if (elapsedTime < startTime) {
      return;
    }

    String lyric = line['lyric'];
    // print("${line["charDelay"]} - ${line["startTime"]}");
    double charDelay = line['charDelay'];
    bool newLine = line['newLine'];

    initializedLyrics = true;
    displayManager.color = colorFromString(line['color']);

    if (newLine) {
      displayManager.setDisplay("");
    }

    List<String> characters = lyric.split("");

    late Future<void> lastCharFuture;

    for (int charIndex = 0; charIndex < characters.length; charIndex++) {
      lastCharFuture = Future.delayed(
          Duration(milliseconds: (charDelay * 1000 * charIndex + 1).toInt()),
          () {
        displayManager.currentDisplay += characters[charIndex];
        setState(() {});
      });
    }

    lastCharFuture.then((_) {
      currentLyricIndex += 1;
      initializedLyrics = false;
      setState(() {});
    });
  }

  void resetLyricsTimings() {
    elapsedTime = 0;
    currentLyricIndex = 0;
    ticker.stop(); // to stop checking the lyrics\
    musicManager.stopSong();
  }
}
