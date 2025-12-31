import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../providers/game_provider.dart';
import '../theme.dart';
import 'board_overlay.dart';
import 'settings_screen.dart';
import '../models/chess_persona.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, gameState),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBoard(gameState, gameNotifier),
                      ],
                    ),
                  ),
                ),
              ),
              _buildControls(context, gameState, gameNotifier),
              _buildStatusLine(gameState),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    // Format numbers with commas
    final numberFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    
    // Determine what to show for "Current/Last Move" metrics
    final showLive = !state.isUserTurn; // Always true in AI vs AI usually
    final nodesToDisplay = showLive ? state.currentMoveNodes : (state.lastCalcNodes ?? 0);
    final nodesFormatted = nodesToDisplay.toString().replaceAllMapped(numberFormat, (Match m) => '${m[1]},');
    
    final totalNodesFormatted = state.totalGameNodes.toString().replaceAllMapped(numberFormat, (Match m) => '${m[1]},');
    
    // Forecast Horizon (Depth)
    final depth = state.lastCalcDepth ?? 0;
    
    // Victory Probability
    final cp = state.evaluation; 
    
    String probText = "50% Draw";
    
    if (state.mateIn != null) {
      if (state.mateIn! > 0) {
        // Engine (Black) sees Mate in +X -> Black Mates White?
        // Wait, normally Stockfish "mate x" is relative to side to move.
        // If Black moves and says "mate 5", Black mates in 5.
        // So Mate > 0 means Side-To-Move wins. (Black).
        // Mate < 0 means Side-To-Move loses. (White wins).
        probText = "100% Black";
      } else {
        probText = "100% White";
      }
    } else {
      // CP is relative to Black (Side to move during analysis)
      // Positive = Black Advantage.
      final double blackExponent = -(cp / 400.0);
      final double blackWinProb = 1.0 / (1.0 + pow(10, blackExponent));
      
      final whiteWinProb = 1.0 - blackWinProb;
      
      if (blackWinProb > 0.55) { // Threshold for clarity
         final percent = (blackWinProb * 100).toStringAsFixed(1);
         probText = "$percent% Black";
      } else if (whiteWinProb > 0.55) {
         final percent = (whiteWinProb * 100).toStringAsFixed(1);
         probText = "$percent% White";
      } else {
         probText = "50% Draw";
      }
    }
    
    String displayTitle = "GRANDMASTER";
    String displaySubtitle = "";
    
    if (state.gameMode == GameMode.aiVsAi) {
      final isWhite = state.fen.split(' ')[1] == 'w';
      final currentPersona = isWhite ? state.whitePersona : state.blackPersona;
      
      displayTitle = isWhite ? "WHITE THINKING" : "BLACK THINKING";
      displaySubtitle = "${currentPersona.name.toUpperCase()} (${currentPersona.year})"; // e.g. "FISHER (1972)"
    } else {
      // Human vs AI
      final opponent = state.blackPersona; // For now assuming engine is always "Opponent" persona slot
      displayTitle = "GRANDMASTER";
      displaySubtitle = "VS ${opponent.name.toUpperCase()} (${opponent.year})";
    }

    // Probability Logic (Simplified for Replacer)
    // ...
  
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                displayTitle,
                style: const TextStyle(
                  color: ChessTheme.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: ChessTheme.silver),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
             ],
           ),
           Transform.translate(
             offset: const Offset(0, -5),
             child: Text(
                displaySubtitle,
                style: const TextStyle(
                  color: ChessTheme.silver,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
           ),
           
           const SizedBox(height: 12),
           // ...
              
           // Row 1: Moves Considered & Total
           _buildMetricRow("POSITIONS ANALYZED THIS TURN", nodesFormatted, showLive),
           _buildMetricRow("TOTAL POSITIONS ANALYZED", totalNodesFormatted, false),
              
           const SizedBox(height: 8),
              
           // Row 2: Options, Horizon, Probability
           _buildMetricRow("CURRENT OPTIONS", "${state.legalMovesCount}", false),
           _buildMetricRow("FORECAST HORIZON", "$depth MOVES AHEAD", false),
           _buildMetricRow("VICTORY PROBABILITY", probText, false),
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value, bool highlight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: ChessTheme.silver.withOpacity(0.7),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? ChessTheme.accentGold : ChessTheme.silver,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState state, GameNotifier notifier) {
    final isWhiteBottom = state.playAsWhite; // Rotate based on user preference

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available size
        final availableSize = constraints.maxWidth < constraints.maxHeight - 100 
            ? constraints.maxWidth 
            : constraints.maxHeight - 100;
            
        return SizedBox(
          width: availableSize,
          height: availableSize,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                ChessBoard(
                  controller: notifier.boardController,
                  boardColor: BoardColor.darkBrown,
                  boardOrientation: isWhiteBottom ? PlayerColor.white : PlayerColor.black,
                  onMove: () {
                    final move = notifier.boardController.getSan().last;
                    if (move != null) {
                      notifier.makeMove(move);
                    }
                  },
                ),
                // PV Arrow Overlay - Check Settings
                if (state.showArrows)
                  Positioned.fill(
                    child: BoardOverlay(
                      pv: state.bestMoveSequence,
                      isWhiteBottom: isWhiteBottom,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, GameState state, GameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ChessTheme.glassmorphism,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildControlButton(Icons.undo, 'UNDO', () {}),
            _buildControlButton(Icons.refresh, 'RESET', () => notifier.resetGame()),
            _buildControlButton(Icons.history, 'LOG', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ChessTheme.gold),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: ChessTheme.silver, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLine(GameState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        state.isGameOver 
            ? 'GAME OVER - ${state.winner?.toUpperCase() ?? "DRAW"} WINS'
            : (state.isUserTurn ? 'YOUR TURN' : 'STOCKFISH IS THINKING...'),
        style: TextStyle(
          color: state.isUserTurn ? ChessTheme.gold : ChessTheme.silver,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
