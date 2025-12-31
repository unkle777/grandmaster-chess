import 'package:flutter/material.dart';

// MINIMAL DEBUG MAIN
void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(child: Text("MINIMAL BUILD - IF YOU SEE THIS, FLUTTER IS OK", style: TextStyle(color: Colors.white))),
      ),
    )
  );
}

// REST OF CODE COMMMENTED OUT
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_screen.dart'; // Assuming GameScreen is a ConsumerWidget or similar
import 'theme.dart';

// ...
      title: 'Deep Chess',
      debugShowCheckedModeBanner: false,
      theme: ChessTheme.lightTheme,
      darkTheme: ChessTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const GameScreen(),
    );
  }
}
