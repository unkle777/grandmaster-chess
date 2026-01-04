// Audio Disabled
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/services.dart';
import '../models/chess_persona.dart';

class AudioManager {
  // final AudioPlayer _player = AudioPlayer();
  // final AudioCache _cache = AudioCache(); 
  // SoundEra _currentEra = SoundEra.modern; 

  void setEra(SoundEra era) {
    // _currentEra = era;
  }

  Future<void> playGameOver() async {
    // await _playSound('game_over.mp3');
  }



  void dispose() {
    // _player.dispose();
  }
}
