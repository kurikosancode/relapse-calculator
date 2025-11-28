import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'music_manager.dart';
import 'package:expressions/expressions.dart';
import 'setting_window.dart';
import 'display_manager.dart';
import 'settings_manager.dart';
import 'mode_manager.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calculator | @kurikosancode",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const _CalculatorScreen(),
    );
  }
}

class _CalculatorScreen extends StatefulWidget {
  const _CalculatorScreen();

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<_CalculatorScreen> {
  final DisplayManager _displayManager = DisplayManager();
  final MusicManager _musicManager = MusicManager();
  final SettingsManager _settingsManager = SettingsManager();
  final ModeManager _modeManager = ModeManager();
  final evaluator = const ExpressionEvaluator();
  late Ticker _ticker;
  late final Map manifestMap;
  List<Map<dynamic, dynamic>> _allLyrics = [];
  List<String> _allClearText = [];
  late Map<dynamic, dynamic> _currentLyrics;
  late String _currentClearText;
  bool showingLyrics = false;

  Future<void> getManifestMap() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    manifestMap = json.decode(manifestContent);
  }

  Future<void> _loadLyrics() async {
    await getManifestMap();
    _allLyrics = await getJsonLyrics(manifestMap);
    _allClearText = await getClearTextOptions();
    Object? settingClearText = await _settingsManager.getSetting("clearText");
    Map<dynamic, dynamic>? settingsSongLyrics =
        await _settingsManager.getMap("songLyrics");
    if (settingClearText != null) {
      _currentClearText = settingClearText as String;
    } else {
      _currentClearText = _allClearText[0];
    }
    if (settingsSongLyrics != null) {
      _currentLyrics = settingsSongLyrics;
      _musicManager.loadCurrentSong(manifestMap, _currentLyrics["songName"]);
    } else {
      _currentLyrics = _allLyrics[0];
    }
  }

  void _clearFunction() {
    _textColor = Colors.black;
    setState(_displayManager.clearDisplay);
    _musicManager.stopSong();
  }

  void _showSongSettings() {
    showSettings<Map>(
      context,
      (Map newLyrics) => {
        _currentLyrics = newLyrics,
        _settingsManager.saveMap("songLyrics", newLyrics),
        _clearFunction(),
        _musicManager.loadCurrentSong(manifestMap, _currentLyrics["songName"])
      },
      (Map currentLyric) => formatSongName(currentLyric["songName"]),
      _allLyrics,
    );
  }

  void _showClearSettings() {
    showSettings<String>(
      context,
      (String newClearText) => {
        _settingsManager.saveSettings("clearText", newClearText),
        _currentClearText = newClearText,
        _clearFunction(),
      },
      (String currentLyric) => currentLyric,
      _allClearText,
    );
  }

  double _elapsedTime = 0.0;
  int _currentLyricIndex = 0;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
    _settingsManager.loadSettings();

    _loadLyrics();
  }

  void _onPressed(String text) {
    final actionMap = {
      "C": _handleClearText,
      "=": _handleEqualsText,
      "(": _showClearSettings,
      ")": _showSongSettings,
      "%": _handlePercentageText,
    };

    if (_modeManager.normalMode) {
      setState(() {
        if (text == "=") {
          setState(
              () => _displayManager.setDisplay(_evaluateValue().toString()));
        } else {
          _appendText(text);
        }
      });
    } else {
      setState(() {
        if (actionMap.containsKey(text)) {
          actionMap[text]!();
        } else {
          _appendText(text);
        }
      });
    }
  }

  void _handleClearText() {
    resetLyrics();
    _textColor = Colors.red;
    _displayManager.currentDisplay = _currentClearText;
  }

  void _handleEqualsText() {
    resetLyrics();
    _ticker.start();
    _startLyricsDisplay();
    _musicManager.playSong();
  }

  void _handlePercentageText() {
    resetLyrics();
    _clearFunction();
  }

  void _appendText(String text) {
    if (_displayManager.currentDisplay == "0") {
      _displayManager.currentDisplay = text;
    } else {
      _displayManager.currentDisplay += text;
    }
  }

  double _evaluateValue() {
    return evaluator
        .eval(Expression.parse(_displayManager.currentDisplay), {}).toDouble();
  }

  void resetLyrics() {
    _currentLyricIndex = 0;
    _elapsedTime = 0;
    _ticker.stop();
  }

  void _startLyricsDisplay() {
    setState(() {
      _displayManager.isDisplayingLyrics = true;
      _displayManager.currentDisplay = "";
    });
    _displayLyrics();
  }

  void _onTick(Duration duration) {
    setState(() {
      _elapsedTime = duration.inMilliseconds / 1000;
    });
    if (_displayManager.isDisplayingLyrics) {
      _displayLyrics();
    }
  }

  void _displayLyrics() {
    List<dynamic> lyrics = _currentLyrics["lyrics"];
    for (int i = _currentLyricIndex; i < lyrics.length; i++) {
      var line = lyrics[i];
      double startTime = line['startTime'];
      String lyric = line['lyric'];
      double charDelay = line['charDelay'];
      bool newLine = line['newLine'];

      if (_elapsedTime >= startTime && (!showingLyrics)) {
        showingLyrics = true;
        _textColor = colorFromString(line['color']);

        if (newLine) {
          _displayManager.currentDisplay = "";
        }

        List<String> characters = lyric.split("");

        late Future<void> lastCharFuture;
        for (int charIndex = 0; charIndex < characters.length; charIndex++) {
          lastCharFuture = Future.delayed(
              Duration(
                  milliseconds: (charDelay * 1000 * charIndex + 1).toInt()),
              () {
            _displayManager.currentDisplay += characters[charIndex];
            setState(() {});
          });
        }

        lastCharFuture.then((_) {
          setState(() {
            _currentLyricIndex = i + 1;
            showingLyrics = false;
          });
        });

        break;
      }
    }
  }

  void toggleCalculatorMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched'),
        duration: Duration(seconds: 1),
      ),
    );
    _modeManager.toggleMode();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _musicManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display area
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    _displayManager.currentDisplay,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _textColor),
                  ),
                ],
              ),
            ),
          ),
          // Buttons grid
          Expanded(
            flex: 2, // Half of the screen
            child: Container(
              color: Colors.grey[300], // Entire grid background is gray
              child: Column(
                children: [
                  _buildRow(["C", "(", ")", "/"]),
                  _buildRow(["7", "8", "9", "*"]),
                  _buildRow(["4", "5", "6", "-"]),
                  _buildRow(["1", "2", "3", "+"]),
                  _buildRow(["%", "0", ".", "="]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> texts) {
    return Expanded(
      child: Row(
        children: texts.map((text) {
          bool isDot = text == ".";
          return Expanded(
            child: ElevatedButton(
              onPressed: () => _onPressed(text),
              onLongPress: isDot ? toggleCalculatorMode : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .grey[300], // Button background is slightly darker gray
                foregroundColor: Colors.black, // Button text color
                elevation: 0, // No shadow for a flat look
                padding: const EdgeInsets.all(20), // Increase touch area
              ),
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
