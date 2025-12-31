import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:chess/chess.dart' as chess_pkg hide Color;
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../engine/stockfish_engine.dart';
import '../services/sound_service.dart';
import '../models/chess_persona.dart';

final engineProvider = Provider((ref) {
  print('GAME_PROVIDER: Initializing engineProvider');
  final engine = ChessEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});


enum GameMode {
  humanVsAi,
  aiVsAi,
}

class GameState {
  final String fen;
  final bool isUserTurn;
  final bool isGameOver;
  final String? winner;
  final double evaluation; // + ve white winning
  final int? mateIn;
  final List<String> bestMoveSequence;
  
  // Metrics
  final int currentMoveNodes;
  final int totalGameNodes;
  
  // Persisted Metrics (Last Calculation)
  final int? lastCalcNodes;
  final int? lastCalcDepth;
  final int? lastCalcNps;
  
  // New Metrics
  final int legalMovesCount;
  
  // Settings
  final bool showArrows;
  final GameMode gameMode;
  final ChessPersona whitePersona;
  final ChessPersona blackPersona;
  final bool playAsWhite;

  // Helper for backward compatibility / UI convenience
  ChessPersona get selectedPersona => blackPersona; 

  GameState({
    required this.fen,
    required this.isUserTurn,
    this.isGameOver = false,
    this.winner,
    this.evaluation = 0.0,
    this.mateIn,
    this.bestMoveSequence = const [],
    this.currentMoveNodes = 0,
    this.totalGameNodes = 0,
    this.lastCalcNodes,
    this.lastCalcDepth,
    this.lastCalcNps,
    this.legalMovesCount = 0,
    this.showArrows = false,
    this.gameMode = GameMode.humanVsAi,
    this.playAsWhite = true,
    ChessPersona? whitePersona,
    ChessPersona? blackPersona,
  }) : 
    whitePersona = whitePersona ?? ChessPersona.all.first, 
    blackPersona = blackPersona ?? ChessPersona.all.last; 

  GameState.raw({
    required this.fen,
    required this.isUserTurn,
    required this.isGameOver,
    required this.winner,
    required this.evaluation,
    required this.mateIn,
    required this.bestMoveSequence,
    required this.currentMoveNodes,
    required this.totalGameNodes,
    required this.lastCalcNodes,
    required this.lastCalcDepth,
    required this.lastCalcNps,
    required this.legalMovesCount,
    required this.showArrows,
    required this.gameMode,
    required this.whitePersona,
    required this.blackPersona,
    required this.playAsWhite,
  });

  GameState copyWith({
    String? fen,
    bool? isUserTurn,
    bool? isGameOver,
    String? winner,
    double? evaluation,
    int? mateIn,
    List<String>? bestMoveSequence,
    int? currentMoveNodes,
    int? totalGameNodes,
    int? lastCalcNodes,
    int? lastCalcDepth,
    int? lastCalcNps,
    int? legalMovesCount,
    bool? showArrows,
    GameMode? gameMode,
    ChessPersona? whitePersona,
    ChessPersona? blackPersona,
    bool? playAsWhite,
    // Deprecated argument support
    ChessPersona? selectedPersona,
  }) {
    // Handle legacy updated
    final effectiveBlackPersona = blackPersona ?? selectedPersona ?? this.blackPersona;
    
    return GameState.raw(
      fen: fen ?? this.fen,
      isUserTurn: isUserTurn ?? this.isUserTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
      evaluation: evaluation ?? this.evaluation,
      mateIn: mateIn ?? this.mateIn,
      bestMoveSequence: bestMoveSequence ?? this.bestMoveSequence,
      currentMoveNodes: currentMoveNodes ?? this.currentMoveNodes,
      totalGameNodes: totalGameNodes ?? this.totalGameNodes,
      lastCalcNodes: lastCalcNodes ?? this.lastCalcNodes,
      lastCalcDepth: lastCalcDepth ?? this.lastCalcDepth,
      lastCalcNps: lastCalcNps ?? this.lastCalcNps,
      legalMovesCount: legalMovesCount ?? this.legalMovesCount,
      showArrows: showArrows ?? this.showArrows,
      gameMode: gameMode ?? this.gameMode,
      whitePersona: whitePersona ?? this.whitePersona,
      blackPersona: effectiveBlackPersona,
      playAsWhite: playAsWhite ?? this.playAsWhite,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final ChessEngine _engine;
  final ChessBoardController _boardController = ChessBoardController();
  final SoundService _soundService = SoundService();
  StreamSubscription? _infoSubscription;
  bool _isAiThinking = false;

  GameNotifier(this._engine) : super(
    GameState(
      fen: 'start', 
      isUserTurn: true, 
      playAsWhite: true,
    )
  ) {
    _initEngine();
    // The _initEngine() call was removed here as per instruction.
    // The logic from the removed _initEngine method should be integrated directly into the constructor or another appropriate place if needed.
    // For now, just removing the method definition.
  }

  ChessBoardController get boardController => _boardController;

  void _initEngine() async {
    await _engine.startNewGame();
    _applyPersonaSettings();

    // Subscribe to engine info
    _infoSubscription = _engine.infoStream.listen((info) {
      if (mounted) {
        state = state.copyWith(
          evaluation: info.evaluation,
          mateIn: info.mateIn,
          currentMoveNodes: info.nodes,
          // Update last metrics live as well, so they are ready when search stops
          lastCalcNodes: info.nodes,
          lastCalcDepth: info.depth,
          lastCalcNps: info.nps,
        );
      }
    });

    // Initial Trigger for AI if needed
    if (state.gameMode == GameMode.aiVsAi) {
      _triggerAiMove();
    } else if (state.gameMode == GameMode.humanVsAi && !state.playAsWhite) {
      // AI moves first if User is Black
      _triggerAiMove();
    }
  }

  
  
  void _applyPersonaSettings() {
    // Apply settings based on whose turn it is
    // If Human vs AI: always apply Black (opponent) persona if User=White, or White if User=Black
    if (state.gameMode == GameMode.humanVsAi) {
      // If user is White, engine is Black. If user is Black, engine is White.
      final enginePersona = state.playAsWhite ? state.blackPersona : state.whitePersona;
      _engine.setLevel(enginePersona.skillLevel);
    } else {
      // AI vs AI: Set based on current turn
      final activePersona = _boardController.getFen().split(' ')[1] == 'w' 
          ? state.whitePersona 
          : state.blackPersona;
      _engine.setLevel(activePersona.skillLevel);
    }
  }
  
  void updateSettings({
    bool? showArrows, 
    ChessPersona? persona, 
    GameMode? gameMode,
    ChessPersona? whitePersona,
    ChessPersona? blackPersona,
    bool? playAsWhite,
  }) {
    state = state.copyWith(
      showArrows: showArrows, 
      selectedPersona: persona, // Legacy/Black update
      gameMode: gameMode,
      whitePersona: whitePersona,
      blackPersona: blackPersona,
      playAsWhite: playAsWhite,
    );
    
    // If we changed sides or mode, we might need to trigger AI
    if (gameMode == GameMode.aiVsAi && !state.isGameOver && !_isAiThinking) {
      _triggerAiMove();
    } else if (gameMode == GameMode.humanVsAi && !state.isGameOver && !_isAiThinking) {
       // If user switched to Black and it's White's turn (start), AI should move
       final isWhiteTurn = _boardController.getFen().split(' ')[1] == 'w';
       if (!state.playAsWhite && isWhiteTurn) {
         _triggerAiMove();
       }
    }
  }

  void _playMoveSound(String moveSan) {
    if (state.isGameOver) {
      _soundService.playGameOver();
      return;
    }

    if (moveSan.contains('#') || moveSan.contains('+')) {
      _soundService.playCheck();
    } else if (moveSan.contains('x')) {
      _soundService.playCapture();
    } else {
      _soundService.playMove();
    }
  }

  // Unified Move Trigger for AI
  void _triggerAiMove() async {
    if (state.isGameOver || _isAiThinking) return;
    
    _isAiThinking = true;
    
    try {
      // Determine active persona
      final isWhiteTurn = _boardController.getFen().split(' ')[1] == 'w';
      final activePersona = isWhiteTurn ? state.whitePersona : state.blackPersona;
      
      // Set engine skill
      await _engine.setLevel(activePersona.skillLevel);
      
      // Start Search
      final stopwatch = Stopwatch()..start();
      final depth = activePersona.depthLimit ?? 15;
      final bestMove = await _engine.getBestMove(state.fen, depth: depth);
      
      // Artificial Delay
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 500) { // Reduced delay for snappier feels since we have guards
        await Future.delayed(Duration(milliseconds: 500 - elapsed));
      }
      
      // Accumulate total nodes
      final nodesSearched = state.currentMoveNodes;
      final newTotalNodes = state.totalGameNodes + nodesSearched;

      if (bestMove != null && bestMove.isNotEmpty && mounted) {
        final from = bestMove.substring(0, 2);
        final to = bestMove.substring(2, 4);
        
        try {
          _boardController.makeMove(from: from, to: to);
        } catch (e) {
          // If move fails (illegal?), force game over or stop
          print('Make move failed: $e');
          _checkGameOver();
          return; 
        }
        
        // Update legal moves for NEXT player
        int nextLegalMoves = 0;
        try {
           nextLegalMoves = (_boardController as dynamic).game.moves().length;
        } catch (e) { /* ignore */ }
        
        state = state.copyWith(
          fen: _boardController.getFen(), 
          // Logic for isUserTurn: 
          // HvAI: if moved (computer), it's user turn.
          // AIvAI: always "user turn" = false? Or irrelevant.
          isUserTurn: state.gameMode == GameMode.humanVsAi, 
          bestMoveSequence: [bestMove], // Arrow
          totalGameNodes: newTotalNodes,
          lastCalcNodes: nodesSearched,
          legalMovesCount: nextLegalMoves,
        );
        _checkGameOver();
        
        final moveSan = _boardController.getSan().last;
        _playMoveSound(moveSan ?? '');
        
        // If AI vs AI, trigger next move
        if (state.gameMode == GameMode.aiVsAi && !state.isGameOver) {
          // Add small delay to let UI breathe before next move triggering
          Future.delayed(const Duration(milliseconds: 100), () => _triggerAiMove());
        }
      }
    } finally {
      // release lock only if not recursively calling (loop handled by recursive call timing)
      // Actually we must release it so the next call can proceed.
      // But wait: if we call _triggerAiMove recursively at the end, that call will be blocked if we don't release.
      _isAiThinking = false;
    }
  }

  void makeMove(String move) async {
    // Human Move Entry Point (only for HvAI)
    if (state.gameMode == GameMode.aiVsAi) return; // Ignore human input in AIvAI
    if (!state.isUserTurn || state.isGameOver) return;

    // 1. Make User Move
    _boardController.makeMoveWithNormalNotation(move);
    
    int legalMoves = 0;
    try {
       legalMoves = (_boardController as dynamic).game.moves().length;
    } catch (e) { /* ignore */ }

    state = state.copyWith(
      fen: _boardController.getFen(), 
      isUserTurn: false,
      bestMoveSequence: [], 
      currentMoveNodes: 0, 
      legalMovesCount: legalMoves,
    );
    _checkGameOver();
    _playMoveSound(move);

    if (state.isGameOver) return;

    // 2. Trigger AI Response
    _triggerAiMove();
  }
  
  @override
  void resetGame() async {
    // Force stop everything
    _isAiThinking = false; 
    await _engine.stopAnalysis();
    _boardController.resetBoard();
    
    state = GameState(
      fen: 'start', 
      isUserTurn: true, // Will update if AI plays first
      gameMode: state.gameMode,
      whitePersona: state.whitePersona,
      blackPersona: state.blackPersona,
    );
    await _engine.startNewGame();
    
    // If AI vs AI, trigger
    if (state.gameMode == GameMode.aiVsAi) {
      _triggerAiMove();
    } else if (state.gameMode == GameMode.humanVsAi && !state.playAsWhite) {
      // If Human plays Black, AI (White) moves first
      _triggerAiMove();
    }
  }

  void _checkGameOver() {
    final chess = chess_pkg.Chess.fromFEN(_boardController.getFen());
    // Also check for repetition or insufficient material if library supports it, 
    // otherwise rely on stockfish returning 'mate' or 0 score.
    
    if (chess.game_over || chess.in_checkmate || chess.in_stalemate || chess.in_draw) {
      String? winner;
      if (chess.in_checkmate) {
        winner = (chess.turn.toString() == 'Color.WHITE') ? 'Black' : 'White';
      } else {
        winner = 'Draw';
      }
      state = state.copyWith(isGameOver: true, winner: winner);
      _engine.stopAnalysis();
    }
  }


  @override
  void dispose() {
    _infoSubscription?.cancel();
    _soundService.dispose();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.watch(engineProvider));
});
