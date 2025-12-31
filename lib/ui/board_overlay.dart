import 'package:flutter/material.dart';
import '../theme.dart';
import 'dart:math' as math;

class BoardOverlay extends StatelessWidget {
  final List<String> pv;
  final bool isWhiteBottom;

  const BoardOverlay({
    super.key,
    required this.pv,
    this.isWhiteBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ArrowPainter(pv: pv, isWhiteBottom: isWhiteBottom),
        child: Container(),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final List<String> pv;
  final bool isWhiteBottom;

  ArrowPainter({required this.pv, required this.isWhiteBottom});

  @override
  void paint(Canvas canvas, Size size) {
    if (pv.isEmpty) return;

    // Draw the first best move prominently
    final bestMove = pv.first;
    _drawArrow(canvas, size, bestMove, ChessTheme.accentGold.withOpacity(0.8));

    // Optionally draw the response move?
    // if (pv.length > 1) {
    //   _drawArrow(canvas, size, pv[1], ChessTheme.silver.withOpacity(0.5));
    // }
  }

  void _drawArrow(Canvas canvas, Size size, String move, Color color) {
    if (move.length < 4) return;

    final squareSize = size.width / 8;
    final halfSquare = squareSize / 2;

    final fromFile = move.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final fromRank = int.parse(move[1]) - 1;
    final toFile = move.codeUnitAt(2) - 'a'.codeUnitAt(0);
    final toRank = int.parse(move[3]) - 1;

    // Convert to screen coordinates
    // Rank 0 is bottom in chess coords, but screen y grows downwards
    
    double getX(int file) {
      if (isWhiteBottom) {
        return file * squareSize + halfSquare;
      } else {
        return (7 - file) * squareSize + halfSquare;
      }
    }
    
    double getY(int rank) {
      if (isWhiteBottom) {
        return (7 - rank) * squareSize + halfSquare;
      } else {
        return rank * squareSize + halfSquare;
      }
    }

    final startX = getX(fromFile);
    final startY = getY(fromRank);
    final endX = getX(toFile);
    final endY = getY(toRank);

    final paint = Paint()
      ..color = color
      ..strokeWidth = squareSize * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);

    canvas.drawPath(path, paint);

    // Draw Arrowhead
    final angle = math.atan2(endY - startY, endX - startX);
    final arrowSize = squareSize * 0.4;
    final arrowAngle = 25 * math.pi / 180;

    final arrowPath = Path();
    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowSize * math.cos(angle - arrowAngle),
      endY - arrowSize * math.sin(angle - arrowAngle),
    );
    arrowPath.lineTo(
      endX - arrowSize * math.cos(angle + arrowAngle),
      endY - arrowSize * math.sin(angle + arrowAngle),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    return oldDelegate.pv != pv;
  }
}
