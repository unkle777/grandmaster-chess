# Grandmaster Chess ♟️

A high-performance, aesthetically pleasing chess application built with Flutter, powered by the **Stockfish 16** engine.

## Features

-   **Grandmaster Personas**: Play against historically inspired AI personalities (Bernstein, Mephisto, Deep Blue, AlphaZero, Stockfish).
-   **Signature Openings**: AI personas use 80% probability to play their historical signature opening moves (e.g., AlphaZero's English Opening).
-   **Native Performance**: Uses Dart FFI to communicate directly with the C++ Stockfish engine for maximum strength.
-   **Aggressive AI**: Stockfish 16 is tuned with `Contempt: 100` for uncompromising, win-seeking play.
-   **Platform Optimized**: tailored UI for iPhone and iPad.

## Architecture

This project uses a layered architecture:

-   **UI Layer**: Flutter Widgets (GameScreen, CustomBoard) rendered on skia/impeller.
-   **State Management**: `flutter_riverpod` manages the `GameState` (FEN, turn, metrics).
-   **Logic Layer**: `GameProvider` handles the game loop, move validation, and AI triggering.
-   **Engine Layer**:
    -   `ChessEngine` class wraps the `stockfish` package.
    -   **FFI (Foreign Function Interface)**: Communicates with the native Stockfish binary via stdin/stdout streams.
    -   **Recursive AI Loop**: The AI thinking process is asynchronous to keep the UI thread unblocked.

## Platform Limitations

-   **iOS**: The primary target platform. Requires a valid signing identity for physical device deployment due to FFI restrictions.
    -   *Performance*: **Release Mode (`flutter run --release`) is strongly recommended.** Debug mode is significantly slower due to Dart VM overhead on FFI calls.
-   **Android**: Experimental support.
-   **Web**: Not supported (FFI is not available in the browser; requires WebAssembly port, which is not currently implemented).

## Installation

1.  **Prerequisites**: Flutter SDK, Xcode (for iOS).
2.  **Clone**: `git clone https://github.com/unkle777/grandmaster-chess.git`
3.  **Dependencies**: `flutter pub get`
4.  **Run**:
    ```bash
    # For best performance on device:
    flutter run --release
    ```

## Roadmap

-   [ ] **Android Optimization**: Ensure UI scales correctly on varied Android screen sizes.
-   [ ] **Web Assembly (Wasm)**: Port Stockfish to Wasm for web support.
-   [ ] **Cloud Analysis**: Offload deep analysis to a server for battery saving.
-   [ ] **Online Multiplayer**: Play against friends via WebSocket/Firebase.

## Security

-   **Offline**: This app is 100% offline. No telemetry or user data is sent to any server.
-   **Input Validation**: FEN strings are sanitized to prevent UCI command injection.

## License

MIT License. See [LICENSE](LICENSE) for details.
