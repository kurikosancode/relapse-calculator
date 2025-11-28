import 'dart:io';
import 'dart:convert';

class JsonManager {
  String jsonPath;
  late final File file;

  JsonManager(this.jsonPath) {
    file = File(jsonPath);
  }

  void saveJson(Map<dynamic, dynamic> newJson) async {
    String updatedJson = jsonEncode(newJson);

    await file.writeAsString(updatedJson);
  }
}
