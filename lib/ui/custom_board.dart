import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_pkg;
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class CustomBoard extends StatelessWidget {
  final String fen;
  final bool isWhiteBottom;
  final Function(String source, String target) onMove;
  final bool isAiWhite; // Kept for API compatibility but unused for rendering now
  final bool isAiBlack;
  final String? lastMove;
  final bool isLocked;

  const CustomBoard({
    super.key,
    required this.fen,
    required this.isWhiteBottom,
    required this.onMove,
    this.isAiWhite = false,
    this.isAiBlack = true,
    this.lastMove,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Parse FEN
    final chess = chess_pkg.Chess.fromFEN(fen);
    final board = _getBoardArray(chess);

    return LayoutBuilder(
      builder: (context, constraints) {
        final squareSize = constraints.maxWidth / 8;

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          child: Stack(
            children: [
              _buildSquares(squareSize),
              _buildPieces(board, squareSize),
            ],
          ),
        );
      },
    );
  }

  List<List<chess_pkg.Piece?>> _getBoardArray(chess_pkg.Chess chess) {
    final board = List.generate(8, (_) => List<chess_pkg.Piece?>.filled(8, null));
    
    // Handle special 'start' FEN
    String effectiveFen = fen;
    if (effectiveFen.trim() == 'start') {
      effectiveFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
    }
    
    final parts = effectiveFen.split(' ');
    final rows = parts[0].split('/');
    
    // Safety check for invalid FEN
    if (rows.length != 8) return board;
    
    for (int r = 0; r < 8; r++) {
      int file = 0;
      for (int c = 0; c < rows[r].length; c++) {
        final char = rows[r][c];
        if (RegExp(r'\d').hasMatch(char)) {
          file += int.parse(char);
        } else {
          final color = (char.toUpperCase() == char) ? chess_pkg.Color.WHITE : chess_pkg.Color.BLACK;
          final type = _getTypeFromChar(char);
          board[r][file] = chess_pkg.Piece(type, color);
          file++;
        }
      }
    }
    return board;
  }
  
  chess_pkg.PieceType _getTypeFromChar(String char) {
    switch (char.toLowerCase()) {
      case 'p': return chess_pkg.PieceType.PAWN;
      case 'r': return chess_pkg.PieceType.ROOK;
      case 'n': return chess_pkg.PieceType.KNIGHT;
      case 'b': return chess_pkg.PieceType.BISHOP;
      case 'q': return chess_pkg.PieceType.QUEEN;
      case 'k': return chess_pkg.PieceType.KING;
      default: return chess_pkg.PieceType.PAWN;
    }
  }

  Widget _buildSquares(double squareSize) {
    return Column(
      children: List.generate(8, (row) {
        final rankIndex = isWhiteBottom ? 7 - row : row;
        return Row(
          children: List.generate(8, (col) {
            final fileIndex = isWhiteBottom ? col : 7 - col;
            final isLight = (rankIndex + fileIndex) % 2 != 0; 
            
            return Container(
              width: squareSize,
              height: squareSize,
              color: isLight ? ChessTheme.boardLight : ChessTheme.boardDark,
              child: DragTarget<String>(
                onWillAccept: (data) => !isLocked,
                onAccept: (sourceSquare) {
                  final targetSquare = _getAlgebraic(fileIndex, rankIndex);
                  if (sourceSquare != targetSquare) {
                    onMove(sourceSquare, targetSquare);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: candidateData.isNotEmpty 
                      ? BoxDecoration(color: ChessTheme.trafficOrange.withOpacity(0.5)) 
                      : null,
                  );
                },
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildPieces(List<List<chess_pkg.Piece?>> board, double squareSize) {
    return Column(
      children: List.generate(8, (row) {
        final rankIndex = isWhiteBottom ? 7 - row : row; 
        
        return Row(
          children: List.generate(8, (col) {
            final fileIndex = isWhiteBottom ? col : 7 - col;
            
            // Correctly map row/col to board logical indices if flipped
            final pieceRow = row; // FEN data is already top-to-bottom. 
            // WAIT! If !isWhiteBottom, we are drawing from H1 (TopLeft) to A8 (BottomRight)?
            // NO! If !isWhiteBottom (Black View):
            // Row 0 is Rank 1. FEN starts at Rank 8. 
            // So Row 0 (Screen Top) needs Rank 1 (Board Index 7).
            
            final logicalRowIndex = isWhiteBottom ? row : 7 - row;
            final logicalColIndex = isWhiteBottom ? col : 7 - col;
            
            final piece = board[logicalRowIndex][logicalColIndex];
            final squareName = _getAlgebraic(fileIndex, rankIndex);
            
            if (piece == null) return SizedBox(width: squareSize, height: squareSize);

            // Active highlighting via square color is simpler, but if we want piece highlight, we can add it here.
            // For standard pieces, we usually just highlight the square (handled in _buildSquares or separate layer).
            
            final child = _buildPieceSvg(piece, squareSize);
            
            if (isLocked) return SizedBox(width: squareSize, height: squareSize, child: child);

            return Draggable<String>(
              data: squareName,
              feedback: SizedBox(width: squareSize, height: squareSize, child: child),
              childWhenDragging: SizedBox(width: squareSize, height: squareSize), 
              child: SizedBox(width: squareSize, height: squareSize, child: child),
            );
          }),
        );
      }),
    );
  }
  
  Widget _buildPieceSvg(chess_pkg.Piece piece, double size) {
    // Assets: wP.svg, bK.svg etc.
    final colorPrefix = piece.color == chess_pkg.Color.WHITE ? 'w' : 'b';
    final typeSuffix = _getTypeSuffix(piece.type);
    final assetPath = "assets/images/pieces/$colorPrefix$typeSuffix.svg";
    
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
    );
  }

  String _getTypeSuffix(chess_pkg.PieceType type) {
     switch (type) {
      case chess_pkg.PieceType.PAWN: return 'P';
      case chess_pkg.PieceType.ROOK: return 'R';
      case chess_pkg.PieceType.KNIGHT: return 'N';
      case chess_pkg.PieceType.BISHOP: return 'B';
      case chess_pkg.PieceType.QUEEN: return 'Q';
      case chess_pkg.PieceType.KING: return 'K';
      default: return 'P';
    }
  }

  String _getAlgebraic(int file, int rank) {
    final fileChar = String.fromCharCode('a'.codeUnitAt(0) + file);
    final rankChar = (rank + 1).toString();
    return "$fileChar$rankChar";
  }
}
