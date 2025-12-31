import 'package:flutter/material.dart';
import '../theme.dart';

class EvaluationBar extends StatelessWidget {
  final double score; // Positive for White advantage
  final int? mateIn;
  final bool whiteAtBottom;

  const EvaluationBar({
    super.key,
    required this.score,
    this.mateIn,
    this.whiteAtBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    double percentage;
    
    if (mateIn != null) {
      if (mateIn! > 0) {
        percentage = 1.0; // White wins
      } else {
        percentage = 0.0; // Black wins
      }
    } else {
      // Clamp score between -5.0 and +5.0 for visual display
      const maxScore = 5.0;
      final clampedScore = score.clamp(-maxScore, maxScore);
      // Map [-5, 5] to [0, 1]
      // -5 -> 0.0
      // 0 -> 0.5
      // 5 -> 1.0
      percentage = (clampedScore + maxScore) / (2 * maxScore);
    }

    // Wrap in TweenAnimationBuilder for smooth updates
    return Container(
      width: 20,
      decoration: BoxDecoration(
        color: ChessTheme.coal,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: percentage),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Stack(
              children: [
                Container(color: Colors.black), // Background (Black's advantage)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value,
                    child: Container(color: Colors.white), // White's advantage
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
