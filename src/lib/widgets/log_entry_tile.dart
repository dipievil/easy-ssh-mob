import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/log_entry.dart';

/// Widget for displaying a log entry in a list
class LogEntryTile extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback? onTap;
  final bool showDetails;

  const LogEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          _getCommandTypeIcon(entry.type),
          color: _getStatusColor(entry.status),
          size: 20,
        ),
        title: Text(
          entry.shortCommand,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_formatTimestamp(entry.timestamp)} • ${entry.durationFormatted}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
            if (entry.hasError)
              Text(
                'Erro: ${entry.stderrPreview}',
                style: const TextStyle(color: Colors.red, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(entry.status),
              color: _getStatusColor(entry.status),
              size: 16,
            ),
            if (entry.exitCode != null)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: entry.exitCode == 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.exitCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        children: [if (showDetails || onTap == null) _buildDetailView(context)],
        onExpansionChanged: (expanded) {
          if (expanded && onTap != null) {
            onTap!();
          }
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('ID', entry.id),
          _buildDetailRow('Comando Completo', entry.command),
          _buildDetailRow('Tipo', _formatCommandType(entry.type)),
          _buildDetailRow('Diretório', entry.workingDirectory),
          _buildDetailRow('Status', _formatStatus(entry.status)),
          _buildDetailRow('Duração', entry.durationFormatted),
          if (entry.exitCode != null)
            _buildDetailRow('Código de Saída', '${entry.exitCode}'),

          if (entry.stdout.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'STDOUT:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                entry.stdout,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],

          if (entry.stderr.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'STDERR:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Text(
                entry.stderr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ],

          if (entry.metadata != null && entry.metadata!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Metadados:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Text(
                entry.metadata.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCommandTypeIcon(CommandType type) {
    switch (type) {
      case CommandType.navigation:
        return FontAwesomeIcons.folderOpen;
      case CommandType.execution:
        return FontAwesomeIcons.play;
      case CommandType.fileView:
        return FontAwesomeIcons.fileAlt;
      case CommandType.system:
        return FontAwesomeIcons.cog;
      case CommandType.custom:
        return FontAwesomeIcons.terminal;
      case CommandType.unknown:
        return FontAwesomeIcons.question;
    }
  }

  IconData _getStatusIcon(CommandStatus status) {
    switch (status) {
      case CommandStatus.success:
        return FontAwesomeIcons.checkCircle;
      case CommandStatus.error:
        return FontAwesomeIcons.exclamationTriangle;
      case CommandStatus.timeout:
        return FontAwesomeIcons.clock;
      case CommandStatus.cancelled:
        return FontAwesomeIcons.ban;
      case CommandStatus.partial:
        return FontAwesomeIcons.exclamationCircle;
    }
  }

  Color _getStatusColor(CommandStatus status) {
    switch (status) {
      case CommandStatus.success:
        return Colors.green;
      case CommandStatus.error:
        return Colors.red;
      case CommandStatus.timeout:
        return Colors.orange;
      case CommandStatus.cancelled:
        return Colors.grey;
      case CommandStatus.partial:
        return Colors.amber;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  String _formatCommandType(CommandType type) {
    switch (type) {
      case CommandType.navigation:
        return 'Navegação';
      case CommandType.execution:
        return 'Execução';
      case CommandType.fileView:
        return 'Visualização';
      case CommandType.system:
        return 'Sistema';
      case CommandType.custom:
        return 'Customizado';
      case CommandType.unknown:
        return 'Desconhecido';
    }
  }

  String _formatStatus(CommandStatus status) {
    switch (status) {
      case CommandStatus.success:
        return 'Sucesso';
      case CommandStatus.error:
        return 'Erro';
      case CommandStatus.timeout:
        return 'Timeout';
      case CommandStatus.cancelled:
        return 'Cancelado';
      case CommandStatus.partial:
        return 'Parcial';
    }
  }
}
