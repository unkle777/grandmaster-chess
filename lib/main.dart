import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_screen.dart';
import 'theme.dart';

void main() {
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
    return MaterialApp(
      title: 'Grandmaster Chess',
      debugShowCheckedModeBanner: false,
      theme: ChessTheme.darkTheme,
      home: const GameScreen(),
    );
  }
}
