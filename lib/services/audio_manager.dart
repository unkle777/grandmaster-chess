// Audio Disabled
// import 'package:audioplayers/audioplayers.dart';
import '../models/chess_persona.dart';

class AudioManager {
  // final AudioPlayer _player = AudioPlayer();
  SoundEra _currentEra = SoundEra.modern; 

  void setEra(SoundEra era) {
    _currentEra = era;
  }
  
  Future<void> playMove() async {}
  Future<void> playCapture() async {}
  Future<void> playGameOver() async {}
  
  void dispose() {}
}
