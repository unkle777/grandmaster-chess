import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/debug_logger.dart';
import '../theme.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('DEBUG LOGS', style: TextStyle(color: ChessTheme.trafficOrange, fontSize: 14, letterSpacing: 1)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: ChessTheme.trafficOrange),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.pause),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            tooltip: 'Auto-scroll',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              DebugLogger().clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<List<LogEntry>>(
        stream: DebugLogger().logStream,
        initialData: DebugLogger().logs,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          
          // Auto-scroll effect
          if (_autoScroll && logs.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isError = log.tag.contains('ERROR') || log.tag.contains('EXCEPTION') || log.tag.contains('CRITICAL');
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '[${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}] ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10, fontFamily: 'Courier'),
                      ),
                      TextSpan(
                        text: '[${log.tag}] ',
                        style: TextStyle(
                          color: isError ? Colors.redAccent : ChessTheme.trafficOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                      ),
                      TextSpan(
                        text: log.message,
                        style: TextStyle(
                          color: isError ? Colors.red[200] : Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
