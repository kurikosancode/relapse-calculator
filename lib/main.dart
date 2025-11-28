import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'music_manager.dart';
import 'display_manager.dart';
import 'settings_manager.dart';
import 'mode_manager.dart';
import 'press_setting.dart';
import 'clear_text_manager.dart';
import 'press_manager.dart';
import 'constants.dart';
import 'math_evaluator.dart';
import 'lyrics_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
  final MathEvaluator mathEvaluator = MathEvaluator();

  late final LyricsManager lyricsManager;
  late final PressManager pressManager;
  late final ClearTextManager clearTextManager;
  late final PressSetting pressSetting;

  Map manifestMap = {};

  Future<void> getManifestMap() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    manifestMap = json.decode(manifestContent);
  }

  Future<void> _loadLyrics() async {
    await _settingsManager.loadSettings();
    await getManifestMap();

    pressSetting.initialize(manifestMap, context);

    lyricsManager.setLyricsList(await getJsonLyrics(manifestMap));

    List<String>? userClearTextList =
        await _settingsManager.getListSetting("userClearTextList");

    if (userClearTextList != null) {
      clearTextManager.setClearTextList(userClearTextList);
    } else {
      clearTextManager.setClearTextList(await getClearTextOptions());
    }

    Object? settingClearText = await _settingsManager.getSetting("clearText");

    bool? settingsCalculatorMode =
        (await _settingsManager.getBoolSetting("calculatorMode"));

    Map<dynamic, dynamic>? settingsSongLyrics =
        await _settingsManager.getMap("songLyrics");

    if (settingClearText != null) {
      clearTextManager.setClearText(settingClearText as String);
    } else {
      clearTextManager.selectFromIndex(0);
    }

    if (settingsSongLyrics != null) {
      lyricsManager.setLyrics(settingsSongLyrics);
      _musicManager.loadCurrentSong(
          manifestMap, settingsSongLyrics["songName"]);
    } else {
      lyricsManager.selectFromIndex(0);
    }

    if (settingsCalculatorMode != null) {
      _modeManager.setMode(settingsCalculatorMode);
    } else {
      _modeManager.setMode(false);
    }
  }

  @override
  void initState() {
    super.initState();

    lyricsManager = LyricsManager(
        musicManager: _musicManager,
        displayManager: _displayManager,
        setState: setState);

    clearTextManager = ClearTextManager(displayManager: _displayManager);

    pressSetting = PressSetting(
        displayManager: _displayManager,
        lyricsManager: lyricsManager,
        settingsManager: _settingsManager,
        musicManager: _musicManager,
        clearTextManager: clearTextManager,
        setState: setState);

    pressManager = PressManager(
        displayManager: _displayManager,
        modeManager: _modeManager,
        clearTextManager: clearTextManager,
        musicManager: _musicManager,
        lyricsManager: lyricsManager,
        pressSetting: pressSetting,
        mathEvaluator: mathEvaluator);

    pressManager.initialize();
    _loadLyrics();
  }

  void toggleCalculatorMode() {
    _modeManager.toggleMode();
    _settingsManager.saveSettings("calculatorMode", _modeManager.normalMode);
    // ScaffoldMessenger.of(context).showSnackBar(
    // SnackBar(
    //   content: Text(
    //       "Switched to ${_modeManager.normalMode ? "Normal Mode" : "Lyrics Mode"}"),
    //   duration: const Duration(seconds: 1),
    // ),
    //);
  }

  @override
  void dispose() {
    lyricsManager.dispose();
    _musicManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: _displayManager.color),
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
              onPressed: () =>
                  setState(() => pressManager.getPressAction(text)),
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
                style: const TextStyle(
                    fontSize: buttonTextSize, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
