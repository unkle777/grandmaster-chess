import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/chess_persona.dart';

class AudioManager {
  final AudioPlayer _player = AudioPlayer();
  final AudioCache _cache = AudioCache(); // Create separate cache
  SoundEra _currentEra = SoundEra.modern; // Default

  void setEra(SoundEra era) {
    // Disabled for stability
    _currentEra = era;
  }

  Future<void> _preloadEraAssets() async {
    // Disabled
  }

  String _getEraPrefix() {
    switch (_currentEra) {
      case SoundEra.vintage:
        return 'sounds/vintage';
      case SoundEra.retro:
        return 'sounds/retro';
      case SoundEra.modern:
        return 'sounds/modern';
    }
  }

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
    final prefix = _getEraPrefix();
    final path = '$prefix/$fileName';
    
    try {
      // Adjust pitch for "menacing" feel 
      // Modern: lower/heavy, Vintage: higher/mechanical
      double pitch = 1.0;
      switch (_currentEra) {
        case SoundEra.vintage:
          pitch = 1.3; // Higher, mechanical tink
          break;
        case SoundEra.retro:
          pitch = 1.0; // Standard
          break;
        case SoundEra.modern:
          pitch = 0.7; // Lower, menacing, heavy
          break;
      }
      
      await _player.setPlaybackRate(pitch);
      await _player.play(AssetSource(path), mode: PlayerMode.lowLatency);
    } catch (e) {
      print('AUDIO: Error playing $path: $e');
      // If specific asset missing, fallback to system sound
      SystemSound.play(SystemSoundType.click);
    }
  }

  void dispose() {
    _player.dispose();
  }
}
