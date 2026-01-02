import 'dart:async';
import 'package:stockfish/stockfish.dart';
import 'engine_info.dart';
import '../services/debug_logger.dart';

export 'engine_info.dart';

class ChessEngine {
  late Stockfish _stockfish;
  final _stdoutController = StreamController<String>.broadcast();
  final _infoController = StreamController<EngineInfo>.broadcast();
  final _readyCompleter = Completer<void>();
  
  Stream<String> get stdout => _stdoutController.stream;
  Stream<EngineInfo> get infoStream => _infoController.stream;

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

    _stockfish.stdout.listen((line) {
      // DebugLogger().log('SF_OUT', line); // Too noisy? Maybe only non-info
      if (!line.startsWith('info')) {
         DebugLogger().log('SF_OUT', line);
      }
      _stdoutController.add(line);
      _parseEngineLine(line);
    });
  }

  void _parseEngineLine(String line) {
    if (!line.startsWith('info')) return;
    
    // Check for pv (Principal Variation)
    if (!line.contains(' pv ')) return; // Only interested in lines with moves

    try {
      double? evaluation;
      int? mateIn;
      int? depth;
      List<String>? pv;

      // Parse Depth
      final depthMatch = RegExp(r'depth (\d+)').firstMatch(line);
      if (depthMatch != null) {
        depth = int.tryParse(depthMatch.group(1) ?? '');
      }

      // Parse Nodes
      int? nodes;
      final nodesMatch = RegExp(r'nodes (\d+)').firstMatch(line);
      if (nodesMatch != null) {
        nodes = int.tryParse(nodesMatch.group(1) ?? '');
      }

      // Parse NPS
      int? nps;
      final npsMatch = RegExp(r'nps (\d+)').firstMatch(line);
      if (npsMatch != null) {
        nps = int.tryParse(npsMatch.group(1) ?? '');
      }

      // Parse Score
      if (line.contains('score mate')) {
        final mateMatch = RegExp(r'score mate (-?\d+)').firstMatch(line);
        if (mateMatch != null) {
          mateIn = int.tryParse(mateMatch.group(1) ?? '');
        }
      } else if (line.contains('score cp')) {
        final cpMatch = RegExp(r'score cp (-?\d+)').firstMatch(line);
        if (cpMatch != null) {
          final cp = int.tryParse(cpMatch.group(1) ?? '');
          if (cp != null) {
            evaluation = cp / 100.0;
          }
        }
      }

      // Parse PV
      final pvIndex = line.indexOf(' pv ');
      if (pvIndex != -1) {
        final pvString = line.substring(pvIndex + 4).trim();
        pv = pvString.split(' ');
      }

      if (evaluation != null || mateIn != null) {
        _infoController.add(EngineInfo(
          evaluation: evaluation,
          mateIn: mateIn,
          depth: depth,
          nodes: nodes,
          nps: nps,
          pv: pv,
        ));
      }
    } catch (e) {
      print('Error parsing engine line: $e');
    }
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
    print("GAME_LOG: Engine requested for FEN: $fen at Depth: $depth");
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

    String positionCommand;
    if (fen == 'start' || fen == 'startpos') {
      positionCommand = 'position startpos';
    } else {
      positionCommand = 'position fen $fen';
    }

    await sendCommand(positionCommand);
    await sendCommand('go depth $depth');

    // Increase timeout to 60s to prevent freezing on deep searches
    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        DebugLogger().log('ENGINE', 'Timeout waiting for bestmove (60s)');
        subscription?.cancel();
        return null;
      },
    );
  }

  /// Starts infinite analysis on the current position
  Future<void> startAnalysis(String fen) async {
    String positionCommand;
    if (fen == 'start' || fen == 'startpos') {
      positionCommand = 'position startpos';
    } else {
      positionCommand = 'position fen $fen';
    }

    await sendCommand(positionCommand);
    await sendCommand('go infinite');
  }

  Future<void> stopAnalysis() async {
    await sendCommand('stop');
  }

  void dispose() {
    _stockfish.dispose();
    _stdoutController.close();
    _infoController.close();
  }
}
