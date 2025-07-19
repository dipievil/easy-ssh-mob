import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/execution_result.dart';

/// Dialog widget to display the results of file execution
class ExecutionResultDialog extends StatelessWidget {
  final ExecutionResult result;
  final String fileName;
  
  const ExecutionResultDialog({
    super.key,
    required this.result,
    required this.fileName,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.hasError ? Icons.error : Icons.check_circle,
            color: result.hasError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Execução: $fileName',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: result.hasError 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    result.statusDescription,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: result.hasError ? Colors.red : Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tempo: ${result.duration.inMilliseconds}ms',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Output content
            Expanded(
              child: result.isEmpty
                  ? const Center(
                      child: Text(
                        'Sem saída',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : DefaultTabController(
                      length: result.stderr.isNotEmpty ? 2 : 1,
                      child: Column(
                        children: [
                          if (result.stderr.isNotEmpty)
                            TabBar(
                              tabs: [
                                Tab(text: 'Saída (${result.stdout.split('\n').length} linhas)'),
                                Tab(text: 'Erros (${result.stderr.split('\n').length} linhas)'),
                              ],
                            ),
                          Expanded(
                            child: result.stderr.isNotEmpty
                                ? TabBarView(
                                    children: [
                                      _buildOutputSection(result.stdout, false),
                                      _buildOutputSection(result.stderr, true),
                                    ],
                                  )
                                : _buildOutputSection(result.stdout, false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        if (!result.isEmpty) ...[
          TextButton.icon(
            onPressed: () => _copyToClipboard(context, result.combinedOutput),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
  
  Widget _buildOutputSection(String content, bool isError) {
    if (content.isEmpty) {
      return Center(
        child: Text(
          isError ? 'Sem erros' : 'Sem saída',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: SelectableText(
          content,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: isError ? Colors.red[700] : Colors.black87,
          ),
        ),
      ),
    );
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}