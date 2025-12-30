import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:chess/chess.dart' as chess_pkg hide Color;
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../engine/stockfish_engine.dart';

final engineProvider = Provider((ref) {
  print('GAME_PROVIDER: Initializing engineProvider');
  final engine = ChessEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

class GameState {
  final String fen;
  final bool isUserTurn;
  final bool isGameOver;
  final String? winner;

  GameState({
    required this.fen,
    required this.isUserTurn,
    this.isGameOver = false,
    this.winner,
  });

  GameState copyWith({
    String? fen,
    bool? isUserTurn,
    bool? isGameOver,
    String? winner,
  }) {
    return GameState(
      fen: fen ?? this.fen,
      isUserTurn: isUserTurn ?? this.isUserTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final ChessEngine _engine;
  final ChessBoardController _boardController = ChessBoardController();

  GameNotifier(this._engine) : super(GameState(fen: 'start', isUserTurn: true)) {
    _initEngine();
  }

  ChessBoardController get boardController => _boardController;

  void _initEngine() async {
    await _engine.startNewGame();
    await _engine.setLevel(20); // Unbeatable mode
  }

  void makeMove(String move) async {
    if (!state.isUserTurn || state.isGameOver) return;

    _boardController.makeMoveWithNormalNotation(move);
    state = state.copyWith(fen: _boardController.getFen(), isUserTurn: false);

    _checkGameOver();

    if (!state.isGameOver) {
      final bestMove = await _engine.getBestMove(state.fen);
      if (bestMove != null) {
        // Stockfish move is in UCI format (e.g., e2e4)
        final from = bestMove.substring(0, 2);
        final to = bestMove.substring(2, 4);
        _boardController.makeMove(from: from, to: to);
        state = state.copyWith(fen: _boardController.getFen(), isUserTurn: true);
        _checkGameOver();
      }
    }
  }

  void _checkGameOver() {
    final chess = chess_pkg.Chess.fromFEN(_boardController.getFen());
    if (chess.game_over) {
      String? winner;
      if (chess.in_checkmate) {
        winner = (chess.turn.toString() == 'Color.WHITE') ? 'Black' : 'White';
      }
      state = state.copyWith(isGameOver: true, winner: winner);
    }
  }

  void resetGame() {
    _boardController.resetBoard();
    state = GameState(fen: 'start', isUserTurn: true);
    _initEngine();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.watch(engineProvider));
});
