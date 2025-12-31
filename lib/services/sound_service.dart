import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  
  // Cache players for low latency? 
  // AudioPlayers mode default is low latency for short sounds.

  Future<void> playMove() async {
    await _playSound('move.mp3');
  }

  Future<void> playCapture() async {
    await _playSound('capture.mp3');
  }

  Future<void> playCheck() async {
    await _playSound('check.mp3');
  }

  Future<void> playGameOver() async {
    await _playSound('game_over.mp3');
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print('Error playing sound $fileName: $e');
      // Fallback
      SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _player.dispose();
  }
}
