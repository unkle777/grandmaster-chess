import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_pkg hide Color;
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../engine/stockfish_engine.dart';
import '../services/audio_manager.dart';
import '../models/chess_persona.dart';
import '../services/debug_logger.dart';

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
  final String? lastMoveLan; // e.g. e2e4
  
  // Metrics
  final int currentMoveNodes;
  final int totalGameNodes; // Total GLOBAL
  final int whiteTotalNodes; // NEW
  final int blackTotalNodes; // NEW
  
  final int whiteLastTurnNodes; // For displaying "Positions Assessed" this turn
  final int blackLastTurnNodes; // For displaying "Positions Assessed" this turn
  
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
    this.lastMoveLan,
    this.currentMoveNodes = 0,
    this.totalGameNodes = 0,
    this.whiteTotalNodes = 0,
    this.blackTotalNodes = 0,
    this.whiteLastTurnNodes = 0,
    this.blackLastTurnNodes = 0,
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
    required this.lastMoveLan,
    required this.currentMoveNodes,
    required this.totalGameNodes,
    required this.whiteTotalNodes,
    required this.blackTotalNodes,
    required this.whiteLastTurnNodes,
    required this.blackLastTurnNodes,
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
    String? lastMoveLan,
    int? currentMoveNodes,
    int? totalGameNodes,
    int? whiteTotalNodes,
    int? blackTotalNodes,
    int? whiteLastTurnNodes,
    int? blackLastTurnNodes,
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
      lastMoveLan: lastMoveLan ?? this.lastMoveLan,
      currentMoveNodes: currentMoveNodes ?? this.currentMoveNodes,
      totalGameNodes: totalGameNodes ?? this.totalGameNodes,
      whiteTotalNodes: whiteTotalNodes ?? this.whiteTotalNodes,
      blackTotalNodes: blackTotalNodes ?? this.blackTotalNodes,
      whiteLastTurnNodes: whiteLastTurnNodes ?? this.whiteLastTurnNodes,
      blackLastTurnNodes: blackLastTurnNodes ?? this.blackLastTurnNodes,
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
} // End GameState

class GameNotifier extends StateNotifier<GameState> {
  final ChessEngine _engine;
  final ChessBoardController _boardController = ChessBoardController();
  final AudioManager _audioManager;
  StreamSubscription? _infoSubscription;
  bool _isAiThinking = false;

  GameNotifier(this._engine, {AudioManager? audioManager}) 
      : _audioManager = audioManager ?? AudioManager(),
        super(
    GameState(
      fen: 'start', 
      isUserTurn: true, // Default is White Human vs AI White? No.
      // logic: default playAsWhite=true. So isUserTurn=true.
      playAsWhite: true,
    )
  ) {
    _initEngine();
  }

  ChessBoardController get boardController => _boardController;
  GameState get currentState => state; // Exposed for testing

  void _initEngine() async {
    await _engine.startNewGame();
    _applyPersonaSettings();

    // Set initial audio era
    _audioManager.setEra(state.blackPersona.era);

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
          // Removed LastNodes specific tracking here, relying on total updates at move end
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
    final oldBlackPersona = state.blackPersona;

    state = state.copyWith(
      showArrows: showArrows, 
      selectedPersona: persona, // Legacy/Black update
      gameMode: gameMode,
      whitePersona: whitePersona,
      blackPersona: blackPersona,
      playAsWhite: playAsWhite,
    );
     
    // Check if era changed (mainly dependent on opponent/black persona in current simpler logic)
    if (state.blackPersona != oldBlackPersona) {
       _audioManager.setEra(state.blackPersona.era);
    }
    
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
      _audioManager.playGameOver();
      return;
    }

    if (moveSan.contains('#') || moveSan.contains('+')) {
      // _audioManager.playCheck();
    } else if (moveSan.contains('x')) {
      // _audioManager.playCapture();
    } else {
      // _audioManager.playMove();
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
      
      DebugLogger().log('AI', 'Turn: ${isWhiteTurn ? "White" : "Black"} (${activePersona.name})');
      
      // Set engine skill
      await _engine.setLevel(activePersona.skillLevel);

      // Switch audio bank to moving persona's era
      _audioManager.setEra(activePersona.era);
      
      DebugLogger().log('AI', 'Searching depth ${activePersona.depthLimit ?? 15}...');

      // Start Search
      final stopwatch = Stopwatch()..start();
      final depth = activePersona.depthLimit ?? 15;
      
      String? bestMove = await _engine.getBestMove(state.fen, depth: depth);
      
      // Retry Logic if timeout/null
      if (bestMove == null) {
         DebugLogger().log('AI', 'Search timed out / null. Retrying at lower depth (10)...');
         bestMove = await _engine.getBestMove(state.fen, depth: 10);
         
         if (bestMove == null) {
             DebugLogger().log('AI_CRITICAL', 'Retry failed. Forcing random legal move or skipping.');
             // Extreme fallback: could ask engine for ANY move or just stop.
             // For now, let's stop recursion to prevent stack overflow/freeze loop, but log it loudly.
             _isAiThinking = false; 
             return;
         }
      }
      
      DebugLogger().log('AI', 'Best move found: $bestMove');

      // Artificial Delay
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 500) { // Reduced delay for snappier feels since we have guards
        await Future.delayed(Duration(milliseconds: 500 - elapsed));
      }
      
      // Accumulate total nodes
      final nodesSearched = state.currentMoveNodes;
      final newTotalNodes = state.totalGameNodes + nodesSearched;
      final newWhiteTotal = isWhiteTurn ? state.whiteTotalNodes + nodesSearched : state.whiteTotalNodes;
      final newBlackTotal = !isWhiteTurn ? state.blackTotalNodes + nodesSearched : state.blackTotalNodes;

      if (bestMove.isNotEmpty && mounted) {
        final from = bestMove.substring(0, 2);
        final to = bestMove.substring(2, 4);
        
        try {
          // Note: controller.makeMove doesn't support promotion arg directly in this version. 
          _boardController.makeMove(from: from, to: to);
        } catch (e) {
          DebugLogger().log('AI_ERROR', 'Make move failed: $e');
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
           isUserTurn: state.gameMode == GameMode.humanVsAi, 
          bestMoveSequence: [bestMove], 
          lastMoveLan: bestMove,
          totalGameNodes: newTotalNodes,
          whiteTotalNodes: newWhiteTotal,
          blackTotalNodes: newBlackTotal,
          // Update the "Last Move" nodes for the player who just finished thinking
          whiteLastTurnNodes: isWhiteTurn ? nodesSearched : state.whiteLastTurnNodes,
          blackLastTurnNodes: !isWhiteTurn ? nodesSearched : state.blackLastTurnNodes,
          lastCalcNodes: nodesSearched,
          legalMovesCount: nextLegalMoves,
        );
        _checkGameOver();
        
        // If AI vs AI, trigger next move
        if (state.gameMode == GameMode.aiVsAi && !state.isGameOver) {
          // recursion
          Future.delayed(const Duration(milliseconds: 100), () => _triggerAiMove());
        }
      }
    } catch (e) {
       DebugLogger().log('AI_EXCEPTION', e.toString());
    } finally {
      _isAiThinking = false;
    }
  }

  void makeMove(String move) async {
    // Human Move Entry Point (only for HvAI)
    if (state.gameMode == GameMode.aiVsAi) return; // Ignore human input in AIvAI
    if (!state.isUserTurn || state.isGameOver) return;

    // 1. Make User Move
    // 1. Make User Move
    try {
      print("GAME_LOG: User attempting move: '$move'");
      // Use explicit from/to if possible, fallback to notation parsing
      if (move.length == 4 || move.length == 5) {
         final from = move.substring(0, 2);
         final to = move.substring(2, 4);
         final promo = move.length == 5 ? move.substring(4,5) : null;
         print("GAME_LOG: Parsed as FROM: $from, TO: $to, PROMO: $promo");
         
         // Fix: Use makeMove instead of notation if we have LAN coordinates
         // promotion arg not supported in this version of controller wrapper, usually defaults to Q
         _boardController.makeMove(from: from, to: to); 
      } else {
         _boardController.makeMoveWithNormalNotation(move);
      }
      print("GAME_LOG: Move '$move' successful on board.");
    } catch (e) {
      print('GAME_LOG: Human move failed: $e');
      return; 
    }
    
    int legalMoves = 0;
    try {
       legalMoves = (_boardController as dynamic).game.moves().length;
    } catch (e) { /* ignore */ }

    state = state.copyWith(
      fen: _boardController.getFen(), 
      isUserTurn: false,
      bestMoveSequence: [],
      lastMoveLan: move, 
      currentMoveNodes: 0, 
      legalMovesCount: legalMoves,
    );
    _checkGameOver();
    _playMoveSound(move);

    if (state.isGameOver) return;

    // 2. Trigger AI Response
    _triggerAiMove();
  }
  
  void resetGame() async {
    // Force stop everything
    _isAiThinking = false; 
    await _engine.stopAnalysis();
    _boardController.resetBoard();
    
    state = GameState(
      fen: 'start', 
      isUserTurn: state.playAsWhite, // IF User is White, True. If Black, False via AI Trigger
      gameMode: state.gameMode,
      whitePersona: state.whitePersona,
      blackPersona: state.blackPersona,
      playAsWhite: state.playAsWhite,
    );
    await _engine.startNewGame();
    
    // If AI vs AI, trigger
    if (state.gameMode == GameMode.aiVsAi) {
      _triggerAiMove();
    } else if (state.gameMode == GameMode.humanVsAi && !state.playAsWhite) {
      // If Human plays Black, AI (White) moves first
      // isUserTurn starts as false (from above).
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
    _audioManager.dispose();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.watch(engineProvider));
});
