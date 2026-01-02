import 'dart:async';

import 'package:chess/chess.dart' as chess_pkg;
import 'engine_info.dart';

export 'engine_info.dart';

// This is a mock engine for Web support to allow UI testing.
// In a real production scenario, we would use a WASM-based Stockfish for web.
class ChessEngine {
  final _stdoutController = StreamController<String>.broadcast();
  final _infoController = StreamController<EngineInfo>.broadcast();
  Stream<String> get stdout => _stdoutController.stream;
  Stream<EngineInfo> get infoStream => _infoController.stream;

  ChessEngine() {
    print('GRANDMASTER_ENGINE: Web Mock Initialized');
  }

  void sendCommand(String command) {
    print('Engine Stdin: $command');
    if (command == 'isready') {
      _stdoutController.add('readyok');
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

  Future<void> startAnalysis(String fen) async {
    // Mock analysis info
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_infoController.isClosed) return;
      _infoController.add(EngineInfo(
        evaluation: 0.5,
        depth: 10,
        pv: ['e2e4', 'e7e5'],
      ));
    });
  }

  Future<void> stopAnalysis() async {
    // No-op for mock
  }

  void dispose() {
    _stdoutController.close();
    _infoController.close();
  }
}
