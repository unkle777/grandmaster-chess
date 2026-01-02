import 'dart:async';
import 'package:flutter/foundation.dart';

class LogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;

  LogEntry(this.tag, this.message) : timestamp = DateTime.now();

  @override
  String toString() {
    return "[${timestamp.hour}:${timestamp.minute}:${timestamp.second}] [$tag] $message";
  }
}

class DebugLogger {
  // Singleton
  static final DebugLogger _instance = DebugLogger._internal();
  factory DebugLogger() => _instance;
  DebugLogger._internal();

  final List<LogEntry> _logs = [];
  final StreamController<List<LogEntry>> _logStreamController = StreamController.broadcast();

  Stream<List<LogEntry>> get logStream => _logStreamController.stream;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String tag, String message) {
    // Print to console for dev
    if (kDebugMode) {
      print("[$tag] $message");
    }
    
    final entry = LogEntry(tag, message);
    _logs.add(entry);
    
    // Cap logs to prevent memory issues
    if (_logs.length > 500) {
      _logs.removeAt(0);
    }
    
    _logStreamController.add(_logs);
  }

  void clear() {
    _logs.clear();
    _logStreamController.add(_logs);
  }
}
