import 'dart:async';


// This is a mock engine for Web support to allow UI testing.
// In a real production scenario, we would use a WASM-based Stockfish for web.
class ChessEngine {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get stdout => _controller.stream;

  ChessEngine() {
    print('ChessEngine: Web Mock Initialized');
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
    // Return a random or semi-intelligent move just for UI demo on web
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic: try to find a move that is legal
    // In a real mock, we'd use a small chess library to find legal moves.
    // For now, we'll return a common opening move if it's the start
    if (fen == 'start' || fen.contains('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')) {
      return 'e7e5';
    }
    
    return null; // Fallback
  }

  void dispose() {
    _controller.close();
  }
}
