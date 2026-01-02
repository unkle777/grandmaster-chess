import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../theme.dart';
import 'board_overlay.dart';
import 'custom_board.dart';
import 'settings_screen.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, gameState),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBoard(context, gameState, gameNotifier),
                    ],
                  ),
                ),
              ),
            ),
            _buildControls(context, gameState, gameNotifier),
            _buildStatusLine(context, gameState),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "DEEP CHESS",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: ChessTheme.trafficOrange,
                  letterSpacing: 2,
                  fontSize: 24,
                  fontWeight: FontWeight.w900, // Thicker
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).dividerColor),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
            ],
          ),
          Text(
            "HUMAN VS MACHINE",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).dividerColor.withOpacity(0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ChessTheme.koStyle(context),
            child: state.gameMode == GameMode.aiVsAi 
              ? _buildAiMetrics(context, state)
              : _buildHumanMetrics(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMetrics(BuildContext context, GameState state) {
    final numberFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    
    // Nodes
    // Nodes
    final currentNodes = state.currentMoveNodes.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},');
    final whiteLastNodes = state.whiteLastTurnNodes.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},');
    final blackLastNodes = state.blackLastTurnNodes.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},');
    // Totals
    // final totalNodes = state.totalGameNodes.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},'); // used in bottom row via direct state access
    
    // Active Indicator
    // Active Indicator
    final parts = state.fen.split(' ');
    final isWhiteTurn = parts.length > 1 ? parts[1] == 'w' : true;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White Column
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPersonaHeader(context, "WHITE", state.whitePersona.name, isWhiteTurn),
                const SizedBox(height: 8),
                _buildMetricValue(context, "POSITIONS ASSESSED", isWhiteTurn ? currentNodes : whiteLastNodes, isWhiteTurn),
              ],
            )),
            // Vertical Divider
            Container(width: 1, height: 40, color: Theme.of(context).dividerColor.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 8)),
            // Black Column
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPersonaHeader(context, "BLACK", state.blackPersona.name, !isWhiteTurn),
                const SizedBox(height: 8),
                _buildMetricValue(context, "POSITIONS ASSESSED", !isWhiteTurn ? currentNodes : blackLastNodes, !isWhiteTurn),
              ],
            )),
          ],
        ),
        const Divider(height: 16, thickness: 1),
        Row(
          children: [
            Expanded(child: _buildMetricBox(context, 'WHITE TOTAL', _formatNumber(state.whiteTotalNodes))),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricBox(context, 'BLACK TOTAL', _formatNumber(state.blackTotalNodes))),
          ],
        ),
      ],
    );
  }

  Widget _buildHumanMetrics(BuildContext context, GameState state) {
    final numberFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final showLive = !state.isUserTurn;
    final nodesToDisplay = showLive ? state.currentMoveNodes : (state.lastCalcNodes ?? 0);
    final nodesFormatted = nodesToDisplay.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},');
    final totalNodes = state.totalGameNodes.toString().replaceAllMapped(numberFormat, (m) => '${m[1]},');
    final depth = state.lastCalcDepth ?? 0;
    
    final opponent = state.blackPersona; 
    
    return Column(
      children: [
        _buildMetricRow(context, "OPPONENT", "${opponent.name.toUpperCase()} (${opponent.year})", false),
        _buildMetricRow(context, "POSITIONS ASSESSED", nodesFormatted, showLive),
        _buildMetricRow(context, "TOTAL POSITIONS ASSESSED", totalNodes, false),
        const Divider(height: 16, thickness: 1),
        _buildMetricBox(context, "MOVES AHEAD PLANNED", "$depth"),
      ],
    );
  }

  Widget _buildPersonaHeader(BuildContext context, String side, String name, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(side, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 8, 
          color: isActive ? ChessTheme.trafficOrange : Theme.of(context).dividerColor.withOpacity(0.5)
        )),
        const SizedBox(height: 2),
        Text(name.toUpperCase(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 10,
          color: isActive ? ChessTheme.trafficOrange : Theme.of(context).dividerColor
        )),
      ],
    );
  }
  
  Widget _buildMetricValue(BuildContext context, String label, String value, bool highlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 7, color: Theme.of(context).dividerColor.withOpacity(0.5))),
        Text(value, style: GoogleFonts.orbitron(
           color: highlight ? ChessTheme.trafficOrange : Theme.of(context).dividerColor,
           fontSize: 12, 
           fontWeight: FontWeight.bold
        )),
      ],
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, bool highlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 8)),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: highlight ? ChessTheme.trafficOrange : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  


  Widget _buildMetricBox(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: ChessTheme.trafficOrange,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, GameState state, GameNotifier notifier) {
    final isWhiteBottom = state.playAsWhite;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = min(constraints.maxWidth, constraints.maxHeight - 120);
        return Container(
          width: availableSize,
          height: availableSize,
          padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
          ),
          child: Stack(
            children: [
              CustomBoard(
                fen: state.fen,
                isWhiteBottom: isWhiteBottom,
                isAiWhite: state.gameMode == GameMode.aiVsAi || (state.gameMode == GameMode.humanVsAi && !state.playAsWhite),
                isAiBlack: state.gameMode == GameMode.aiVsAi || (state.gameMode == GameMode.humanVsAi && state.playAsWhite),
                lastMove: state.lastMoveLan,
                onMove: (from, to) {
                  notifier.makeMove(from + to);
                },
              ),
              if (state.showArrows)
                Positioned.fill(
                  child: BoardOverlay(
                    pv: state.bestMoveSequence,
                    isWhiteBottom: isWhiteBottom,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, GameState state, GameNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ChessTheme.koStyle(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildControlButton(context, Icons.undo, 'UNDO', () {}),
            _buildControlButton(context, Icons.refresh, 'RESET', () => notifier.resetGame()),
            // Log button removed
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ChessTheme.trafficOrange, size: 20),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 7)),
        ],
      ),
    );
  }

  Widget _buildStatusLine(BuildContext context, GameState state) {
    String statusText = "";
    if (state.isGameOver) {
      if (state.winner == 'Draw') {
        statusText = "GAME DRAWN";
      } else {
        statusText = "CHECKMATE - ${state.winner?.toUpperCase() ?? ''} WINS";
      }
    } else {
      statusText = state.isUserTurn ? "YOUR TURN" : "AI COMPUTING...";
    }

    return Text(
      statusText,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: state.isUserTurn ? ChessTheme.trafficOrange : Theme.of(context).dividerColor,
        fontSize: 12, // Larger
        letterSpacing: 2,
        fontWeight: FontWeight.w900, // Black/Thick
      ),
    );
  }

  String _formatNumber(int? number) {
    if (number == null) return "0";
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toString().replaceAllMapped(reg, (m) => '${m[1]},');
  }
}
