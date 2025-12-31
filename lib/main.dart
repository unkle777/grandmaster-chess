import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_screen.dart'; // Assuming GameScreen is a ConsumerWidget or similar
import 'theme.dart';

// Assuming gameProvider is defined elsewhere, e.g., in 'ui/game_screen.dart'
// For this edit, we'll assume it's available where needed.
// final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier()); // Example

void main() {
  print("DEBUG: Main App Started");
  runApp(
    const ProviderScope(
      child: GrandmasterChessApp(),
    ),
  );
}

class GrandmasterChessApp extends StatelessWidget {
  const GrandmasterChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("DEBUG: GrandmasterChessApp Build"); // Added print statement
    return MaterialApp(
      title: 'Deep Chess',
      debugShowCheckedModeBanner: false,
      theme: ChessTheme.lightTheme,
      darkTheme: ChessTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const GameScreen(),
    );
  }
}
