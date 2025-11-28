import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;
import 'config.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

// Function to get the lyrics
Future<List<Map<dynamic, dynamic>>> getJsonLyrics(Map manifestMap) async {
  final jsonFiles = manifestMap.keys
      .where((key) =>
          (key as String).contains(baseJsonpath) && key.endsWith('.json'))
      .toList(); // gets all of the paths

  List<Map<dynamic, dynamic>> allJsonData = [];

  for (String filePath in jsonFiles) {
    String songName = path.basenameWithoutExtension(filePath);
    String jsonString = await rootBundle.loadString(filePath);
    allJsonData.add({"songName": songName, "lyrics": json.decode(jsonString)});
  }
  return allJsonData;
}

String formatSongName(String fileName) {
  return fileName
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Color colorFromString(String color) {
  switch (color.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    default:
      return Colors.black;
  }
}

Future<List<String>> getClearTextOptions() async {
  return List<String>.from(json.decode(
      await rootBundle.loadString(clearTextOptionsPath))["textOptions"]);
}
