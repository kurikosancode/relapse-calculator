import 'package:audioplayers/audioplayers.dart';

class MusicManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AssetSource _currentSong;
  bool _hasSong = false;

  Future<void> playSong() async {
    if (!_hasSong) {
      print("no song");
      return;
    }
    await _audioPlayer.play(_currentSong);
  }

  Future<void> stopSong() async {
    await _audioPlayer.stop();
  }

  void setCurrentSong(String filePath) {
    _currentSong = AssetSource(filePath);
  }

  bool isSongAvailable(Map manifestMap, String filePath) {
    return manifestMap.containsKey(filePath);
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void loadCurrentSong(Map manifestMap, String songName) {
    String filePath = "songs/$songName.mp3";
    String assetPath = "assets/$filePath";
    _hasSong = isSongAvailable(manifestMap, assetPath);
    if (_hasSong) {
      _currentSong = AssetSource(filePath);
    }
  }
}
