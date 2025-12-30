import 'dart:async';
import 'package:stockfish_flutter_plus/stockfish_flutter_plus.dart';

class ChessEngine {
  late Stockfish _stockfish;
  final _controller = StreamController<String>.broadcast();
  final _readyCompleter = Completer<void>();
  Stream<String> get stdout => _controller.stream;

  ChessEngine() {
    print('GRANDMASTER_ENGINE: Native Stockfish Initializing...');
    _stockfish = Stockfish();
    
    // Listen to state changes to know when engine is ready
    _stockfish.state.addListener(() {
      if (_stockfish.state.value == StockfishState.ready && !_readyCompleter.isCompleted) {
        print('GRANDMASTER_ENGINE: Native Stockfish Ready');
        _readyCompleter.complete();
      }
    });

    _stockfish.stdout.listen((event) {
      _controller.add(event);
    });
  }

  Future<void> sendCommand(String command) async {
    await _readyCompleter.future;
    _stockfish.stdin = command;
  }

  Future<void> setLevel(int level) async {
    await sendCommand('setoption name Skill Level value $level');
  }

  Future<void> startNewGame() async {
    await sendCommand('ucinewgame');
    await sendCommand('isready');
  }

  Future<String?> getBestMove(String fen, {int depth = 15}) async {
    final completer = Completer<String?>();
    
    StreamSubscription? subscription;
    subscription = stdout.listen((line) {
      if (line.startsWith('bestmove')) {
        final parts = line.split(' ');
        if (parts.length >= 2) {
          subscription?.cancel();
          completer.complete(parts[1]);
        } else {
          subscription?.cancel();
          completer.complete(null);
        }
      }
    });

    await sendCommand('position fen $fen');
    await sendCommand('go depth $depth');

    // Add a timeout just in case
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription?.cancel();
        return null;
      },
    );
  }

  void dispose() {
    _stockfish.dispose();
    _controller.close();
  }
}
