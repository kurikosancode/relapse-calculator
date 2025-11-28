import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsManager {
  late SharedPreferences _preferences;

  Future<void> loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> saveSettings(String key, dynamic value) async {
    Map setMap = {
      String: _preferences.setString,
      bool: _preferences.setBool,
      int: _preferences.setInt,
      double: _preferences.setDouble,
      List<String>: _preferences.setStringList
    };

    Type valueType = value.runtimeType;
    if (setMap.containsKey(valueType)) {
      setMap[valueType](key, value);
    }
  }

  Future<void> saveMap(String key, Map<dynamic, dynamic> items) async {
    String jsonString = jsonEncode(items);
    await _preferences.setString(key, jsonString);
  }

  Future<Map<dynamic, dynamic>?> getMap(String key) async {
    String? jsonString = _preferences.getString(key);
    if (jsonString == null) {
      return null;
    }
    return Map<dynamic, dynamic>.from(jsonDecode(jsonString));
  }

  Future<Object?> getSetting(String key) async {
    return _preferences.getString(key);
  }

  Future<bool?> getBoolSetting(String key) async {
    return _preferences.getBool(key);
  }

  Future<List<String>?> getListSetting(String key) async {
    return _preferences.getStringList(key);
  }

  // Delete setting
  Future<void> deleteSettings(String key) async {
    await _preferences.remove(key);
  }
}
