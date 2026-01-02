# Grandmaster Chess

A beautiful, unbeatable chess application built with Flutter and Stockfish.

## Features
- **Stockfish Engine**: Level 20 intelligence (unbeatable) on iOS with recursive AI loop.
- **Premium Design**: Midnight & Gold aesthetic with glassmorphism and custom typography.
- **Advanced Metrics**:
    - **Live Node Count**: See positions assessed for the current turn.
    - **Split Totals**: Track total white vs. black search nodes separately.
- **Debug Tools**: Built-in engine logger and error retry system to prevent freezes.
- **Cross-Platform**: Optimized for iOS with a functional UI demo for Web (Chrome).
- **State Management**: Built with Riverpod for reactive and clean code.

## Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- Xcode (for iOS builds)
- Chrome (for web verification)

### Installation
1. Clone or copy the project to your local machine.
2. Run `flutter pub get` in the project root.

### Running the App
- **iOS (Physical)**: 
  ```bash
  flutter run --release
  ```
  *Note: Release mode is required for full engine performance and to prevent "Debug" banner overlay.*

- **Web**: `flutter run -d chrome --web-port 8080`

### Troubleshooting
- **AI Freeze**: If the engine takes >60s, it will auto-retry. Check **Settings > View Debug Logs** for details.
- **iOS Build**: Requires valid signing identity. Ensure `stockfish` NNUE paths are set correctly in `evaluate.h`.

## Project Structure
- `lib/engine/`: Stockfish integration & Native/Web adaptations.
- `lib/providers/`: Riverpod state management (`GameNotifier`, `GameState`).
- `lib/ui/`: Game screens, board visualization, and metrics.
- `lib/services/`: Audio (disabled) and Debug Logger.
- `lib/theme.dart`: Design system configuration.

## Assets
- High-fidelity piece rendering is integrated via the `flutter_chess_board` package with custom theme styling.

---
*Developed by Antigravity*
