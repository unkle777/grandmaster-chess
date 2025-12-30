import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chess/chess.dart' as chess_pkg;

// This is a mock engine for Web support to allow UI testing.
// In a real production scenario, we would use a WASM-based Stockfish for web.
class ChessEngine {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get stdout => _controller.stream;

  ChessEngine() {
    print('GRANDMASTER_ENGINE: Web Mock Initialized');
  }

  void sendCommand(String command) {
    print('Engine Stdin: $command');
    if (command == 'isready') {
      _controller.add('readyok');
    }
  }

  Future<void> setLevel(int level) async {}

  Future<void> startNewGame() async {
    sendCommand('ucinewgame');
    sendCommand('isready');
  }

  Future<String?> getBestMove(String fen, {int depth = 15}) async {
    // Return a random legal move for UI demo on web
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final chess = (fen == 'start' || fen.isEmpty) ? chess_pkg.Chess() : chess_pkg.Chess.fromFEN(fen);
      final moves = chess.generate_moves();
      
      if (moves.isEmpty) return null;
      
      // Pick a random legal move for the mock
      moves.shuffle();
      final move = moves.first;
      
      // Stockfish UCI format helper (e.g. e2e4)
      String from = chess_pkg.Chess.algebraic(move.from);
      String to = chess_pkg.Chess.algebraic(move.to);
      return '$from$to';
    } catch (e) {
      print('Mock Engine Error: $e');
      return null;
    }
  }

  void dispose() {
    _controller.close();
  }
}
