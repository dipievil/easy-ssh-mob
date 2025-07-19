import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ssh_provider.dart';
import '../models/execution_result.dart';
import '../models/ssh_file.dart';

/// Terminal-like screen for advanced command execution and output viewing
class TerminalScreen extends StatefulWidget {
  final ExecutionResult? initialResult;
  final String? initialCommand;
  
  const TerminalScreen({
    super.key,
    this.initialResult,
    this.initialCommand,
  });

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalEntry> _history = [];
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    
    // Add initial result if provided
    if (widget.initialResult != null) {
      _history.add(TerminalEntry(
        command: widget.initialCommand ?? 'File execution',
        result: widget.initialResult!,
        timestamp: widget.initialResult!.timestamp,
      ));
    }
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty || _isExecuting) return;

    setState(() {
      _isExecuting = true;
    });

    final sshProvider = Provider.of<SshProvider>(context, listen: false);
    final startTime = DateTime.now();
    
    try {
      // Add command to history immediately
      final entry = TerminalEntry(
        command: command,
        result: null,
        timestamp: startTime,
        isExecuting: true,
      );
      
      setState(() {
        _history.add(entry);
        _commandController.clear();
      });
      
      // Scroll to bottom
      _scrollToBottom();
      
      // Execute command
      final output = await sshProvider.executeCommandWithResult(command);
      final duration = DateTime.now().difference(startTime);
      
      final result = ExecutionResult(
        stdout: output ?? '',
        stderr: '', // Basic execution doesn't separate stderr
        exitCode: output != null ? 0 : -1,
        duration: duration,
        timestamp: startTime,
      );
      
      // Update the entry with result
      setState(() {
        final index = _history.length - 1;
        _history[index] = _history[index].copyWith(
          result: result,
          isExecuting: false,
        );
      });
      
    } catch (e) {
      // Handle execution error
      final result = ExecutionResult(
        stdout: '',
        stderr: e.toString(),
        exitCode: -1,
        duration: DateTime.now().difference(startTime),
        timestamp: startTime,
      );
      
      setState(() {
        final index = _history.length - 1;
        _history[index] = _history[index].copyWith(
          result: result,
          isExecuting: false,
        );
      });
    } finally {
      setState(() {
        _isExecuting = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar histórico',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Terminal output area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _history.isEmpty
                  ? const Center(
                      child: Text(
                        'Terminal pronto. Digite um comando abaixo.',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'monospace',
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        return _buildTerminalEntry(entry);
                      },
                    ),
            ),
          ),
          
          // Command input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.green)),
            ),
            child: Row(
              children: [
                const Text(
                  '\$ ',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Digite um comando...',
                      hintStyle: TextStyle(color: Colors.green),
                    ),
                    enabled: !_isExecuting,
                    onSubmitted: (_) => _executeCommand(),
                  ),
                ),
                IconButton(
                  onPressed: _isExecuting ? null : _executeCommand,
                  icon: _isExecuting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalEntry(TerminalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Command line
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              children: [
                const TextSpan(
                  text: '\$ ',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: entry.command,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Result output
          if (entry.isExecuting)
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Executando...',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else if (entry.result != null) ...[
            if (entry.result!.stdout.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SelectableText(
                  entry.result!.stdout,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            if (entry.result!.stderr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SelectableText(
                  entry.result!.stderr,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            if (entry.result!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  '(sem saída)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Model for terminal history entries
class TerminalEntry {
  final String command;
  final ExecutionResult? result;
  final DateTime timestamp;
  final bool isExecuting;

  const TerminalEntry({
    required this.command,
    required this.result,
    required this.timestamp,
    this.isExecuting = false,
  });

  TerminalEntry copyWith({
    String? command,
    ExecutionResult? result,
    DateTime? timestamp,
    bool? isExecuting,
  }) {
    return TerminalEntry(
      command: command ?? this.command,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isExecuting: isExecuting ?? this.isExecuting,
    );
  }
}