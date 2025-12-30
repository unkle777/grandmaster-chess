# Grandmaster Chess

A beautiful, unbeatable chess application built with Flutter and Stockfish.

## Features
- **Stockfish Engine**: Level 20 intelligence (unbeatable) on iOS.
- **Premium Design**: Midnight & Gold aesthetic with glassmorphism and custom typography.
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
- **iOS**: `flutter run`
- **Web**: `flutter run -d chrome --web-port 8080`

## Project Structure
- `lib/engine/`: Stockfish integration logic.
- `lib/providers/`: Riverpod state management.
- `lib/ui/`: Game screens and widgets.
- `lib/theme.dart`: Premium design system configuration.

## Assets
- High-fidelity piece rendering is integrated via the `flutter_chess_board` package with custom theme styling.

---
*Developed by Antigravity*
