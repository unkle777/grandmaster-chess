import 'dart:async';
import 'engine_info.dart';
export 'engine_info.dart';

class ChessEngine {
  Stream<String> get stdout => throw UnimplementedError();
  Stream<EngineInfo> get infoStream => throw UnimplementedError();

  void sendCommand(String command) => throw UnimplementedError();
  Future<void> setLevel(int level) => throw UnimplementedError();
  Future<void> startNewGame() => throw UnimplementedError();
  Future<String?> getBestMove(String fen, {int depth = 15}) => throw UnimplementedError();
  Future<void> startAnalysis(String fen) => throw UnimplementedError();
  Future<void> stopAnalysis() => throw UnimplementedError();
  void dispose() => throw UnimplementedError();
}
