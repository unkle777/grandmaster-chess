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

  Future<void> _preloadEraAssets() async {
  }

  String _getEraPrefix() {
    return 'sounds/modern';
  }

  Future<void> playMove() async {
    // await _playSound('move.mp3');
  }

  Future<void> playCapture() async {
    // await _playSound('capture.mp3');
  }

  Future<void> playCheck() async {
    // await _playSound('check.mp3');
  }

  Future<void> playGameOver() async {
    // await _playSound('game_over.mp3');
  }

  Future<void> _playSound(String fileName) async {
    // Disabled
  }

  void dispose() {
    // _player.dispose();
  }
}
