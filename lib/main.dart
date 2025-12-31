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
      title: 'Deep Chess',
      debugShowCheckedModeBanner: false,
      theme: ChessTheme.lightTheme,
      darkTheme: ChessTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const GameScreen(),
    );
  }
}
