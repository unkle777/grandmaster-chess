import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_pkg;
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class CustomBoard extends StatelessWidget {
  final String fen;
  final bool isWhiteBottom;
  final Function(String source, String target) onMove;
  final bool isAiWhite; 
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
        print("DEBUG: CustomBoard LayoutBuilder Constraints: $constraints");
        final squareSize = constraints.maxWidth / 8;

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          child: _buildBoardGrid(board, squareSize),
        );
      },
    );
  }

  // Merged grid builder
  Widget _buildBoardGrid(List<List<chess_pkg.Piece?>> board, double squareSize) {
    return Column(
      children: List.generate(8, (row) {
        return Row(
          children: List.generate(8, (col) {
            // Coordinate Logic
            final rankIndex = isWhiteBottom ? 7 - row : row;
            final fileIndex = isWhiteBottom ? col : 7 - col;
            final squareName = _getAlgebraic(fileIndex, rankIndex);
            
            // Background Color
            final isLight = (rankIndex + fileIndex) % 2 != 0;
            final bgColor = isLight ? ChessTheme.boardLight : ChessTheme.boardDark;

            // Piece Logic
            // Map visual row/col to board data
            // If !isWhiteBottom (Flipped), visual Row 0 is Rank 1 (Index 7).
            // Visual Col 0 is File H (Index 7).
            final logicalRowIndex = isWhiteBottom ? row : 7 - row;
            final logicalColIndex = isWhiteBottom ? col : 7 - col;
            final piece = board[logicalRowIndex][logicalColIndex];
            
            return Container(
              width: squareSize,
              height: squareSize,
              color: bgColor,
              child: DragTarget<String>(
                onWillAccept: (data) => !isLocked,
                onAccept: (sourceSquare) {
                  if (sourceSquare != squareName) {
                    onMove(sourceSquare, squareName);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  // Highlight on drag hover
                  Widget? content = _buildPieceWidget(piece, squareName, squareSize);
                  
                  if (candidateData.isNotEmpty) {
                     return Stack(
                       children: [
                         if (content != null) content,
                         Container(color: ChessTheme.trafficOrange.withOpacity(0.5)),
                       ],
                     );
                  }
                  return content ?? const SizedBox();
                },
              ),
            );
          }),
        );
      }),
    );
  }
  
  Widget? _buildPieceWidget(chess_pkg.Piece? piece, String squareName, double size) {
    if (piece == null) return null;
    
    final child = _buildPieceSvg(piece, size);
    
    if (isLocked) return SizedBox(width: size, height: size, child: child);
    
    return Draggable<String>(
      data: squareName,
      feedback: SizedBox(width: size, height: size, child: child),
      childWhenDragging: SizedBox(width: size, height: size, child: Opacity(opacity: 0.2, child: child)),
      child: SizedBox(width: size, height: size, child: child),
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
  
  Widget _buildPieceSvg(chess_pkg.Piece piece, double size) {
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
