import 'package:audioplayers/audioplayers.dart';

class AudioServices {
  final AudioPlayer _audioPlayer = AudioPlayer();
  void playSound(String soundFile) {
    _audioPlayer.play(AssetSource(soundFile));
  }

  void pauseSound() {
    _audioPlayer.pause();
  }

  void stopSound() {
    _audioPlayer.stop();
  }
}
