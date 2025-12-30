import 'dart:async';

class ChessEngine {
  Stream<String> get stdout => throw UnimplementedError();
  void sendCommand(String command) => throw UnimplementedError();
  Future<void> setLevel(int level) => throw UnimplementedError();
  Future<void> startNewGame() => throw UnimplementedError();
  Future<String?> getBestMove(String fen, {int depth = 15}) => throw UnimplementedError();
  void dispose() => throw UnimplementedError();
}
