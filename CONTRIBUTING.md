# Contributing to Grandmaster Chess

Thank you for your interest in contributing to Grandmaster Chess!

## Getting Started

1.  **Fork the repository**.
2.  **Clone your fork**: `git clone https://github.com/your-username/grandmaster-chess.git`
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

## Development Workflow

-   **Branching**: Create a new branch for your feature or bugfix (`git checkout -b feature/amazing-feature`).
-   **Code Style**: Follow standard Flutter/Dart linting rules.
-   **Testing**: Please ensure `flutter test` passes before submitting.

## Architecture

-   **State Management**: `flutter_riverpod`
-   **Engine**: Stockfish 16 via FFI (`stockfish` package)
-   **UI**: Custom painted chessboard with `flutter_chess_board` logic.

## Pull Requests

1.  Push your branch to your fork.
2.  Open a Pull Request against the `main` branch.
3.  Provide a clear description of your changes.

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
