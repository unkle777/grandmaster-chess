import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart' hide Color;
import '../providers/game_provider.dart';
import '../theme.dart';

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
              _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GRANDMASTER',
                style: TextStyle(
                  color: ChessTheme.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              Text(
                'STOCKFISH LVL 20',
                style: TextStyle(
                  color: ChessTheme.silver,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: ChessTheme.silver),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState state, GameNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight - 100 
            ? constraints.maxWidth 
            : constraints.maxHeight - 100;
            
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ChessBoard(
            controller: notifier.boardController,
            boardColor: BoardColor.darkBrown,
            boardOrientation: PlayerColor.white,
            onMove: () {
              final move = notifier.boardController.getSan().last;
              if (move != null) {
                notifier.makeMove(move);
              }
            },
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
