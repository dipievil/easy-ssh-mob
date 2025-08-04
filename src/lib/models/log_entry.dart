import 'dart:convert';

/// Types of SSH commands for categorization
enum CommandType {
  navigation, // cd, ls, pwd
  execution, // Scripts, binários
  fileView, // cat, tail, head
  system, // ps, df, uname
  custom, // Comandos do drawer
  unknown,
}

/// Status of command execution
enum CommandStatus { success, error, timeout, cancelled, partial }

/// Log entry for SSH commands executed during session
class LogEntry {
  final String id;
  final DateTime timestamp;
  final String command;
  final CommandType type;
  final String workingDirectory;
  final String stdout;
  final String stderr;
  final int? exitCode;
  final Duration duration;
  final CommandStatus status;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.command,
    required this.type,
    required this.workingDirectory,
    required this.stdout,
    required this.stderr,
    this.exitCode,
    required this.duration,
    required this.status,
    this.metadata,
  });

  /// Create LogEntry from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      command: json['command'] as String,
      type: CommandType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CommandType.unknown,
      ),
      workingDirectory: json['workingDirectory'] as String,
      stdout: json['stdout'] as String,
      stderr: json['stderr'] as String,
      exitCode: json['exitCode'] as int?,
      duration: Duration(microseconds: json['durationMicros'] as int),
      status: CommandStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => CommandStatus.error,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert LogEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'command': command,
      'type': type.toString(),
      'workingDirectory': workingDirectory,
      'stdout': stdout,
      'stderr': stderr,
      'exitCode': exitCode,
      'durationMicros': duration.inMicroseconds,
      'status': status.toString(),
      'metadata': metadata,
    };
  }

  /// Format as human-readable text
  String toTextFormat() {
    final buffer = StringBuffer();
    buffer.writeln('=== Command Execution Log ===');
    buffer.writeln('ID: $id');
    buffer.writeln('Timestamp: ${_formatTimestamp(timestamp)}');
    buffer.writeln('Command: $command');
    buffer.writeln('Type: ${_formatCommandType(type)}');
    buffer.writeln('Working Directory: $workingDirectory');
    buffer.writeln('Duration: $durationFormatted');
    buffer.writeln('Status: ${_formatStatus(status)}');
    if (exitCode != null) {
      buffer.writeln('Exit Code: $exitCode');
    }

    if (stdout.isNotEmpty) {
      buffer.writeln('--- STDOUT ---');
      buffer.writeln(stdout);
    }

    if (stderr.isNotEmpty) {
      buffer.writeln('--- STDERR ---');
      buffer.writeln(stderr);
    }

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.writeln('--- METADATA ---');
      buffer.writeln(jsonEncode(metadata));
    }

    return buffer.toString();
  }

  /// Format as CSV row
  String toCsvRow() {
    return [
      _formatTimestamp(timestamp),
      _escapeCsv(command),
      _formatCommandType(type),
      _formatStatus(status),
      durationFormatted,
      _escapeCsv(workingDirectory),
      exitCode?.toString() ?? '',
      _escapeCsv(stdout.replaceAll('\n', '\\n')),
      _escapeCsv(stderr.replaceAll('\n', '\\n')),
    ].join(',');
  }

  /// Check if command has error
  bool get hasError => status == CommandStatus.error || stderr.isNotEmpty;

  /// Check if command was successful
  bool get wasSuccessful =>
      status == CommandStatus.success && (exitCode == null || exitCode == 0);

  /// Get formatted duration
  String get durationFormatted {
    if (duration.inSeconds > 0) {
      return '${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}s';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }

  /// Get short command for display
  String get shortCommand {
    if (command.length <= 50) return command;
    return '${command.substring(0, 47)}...';
  }

  /// Get first line of stdout for preview
  String get stdoutPreview {
    if (stdout.isEmpty) return '';
    final firstLine = stdout.split('\n').first;
    if (firstLine.length <= 100) return firstLine;
    return '${firstLine.substring(0, 97)}...';
  }

  /// Get first line of stderr for preview
  String get stderrPreview {
    if (stderr.isEmpty) return '';
    final firstLine = stderr.split('\n').first;
    if (firstLine.length <= 100) return firstLine;
    return '${firstLine.substring(0, 97)}...';
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// Format command type for display
  String _formatCommandType(CommandType type) {
    switch (type) {
      case CommandType.navigation:
        return 'Navigation';
      case CommandType.execution:
        return 'Execution';
      case CommandType.fileView:
        return 'File View';
      case CommandType.system:
        return 'System';
      case CommandType.custom:
        return 'Custom';
      case CommandType.unknown:
        return 'Unknown';
    }
  }

  /// Format status for display
  String _formatStatus(CommandStatus status) {
    switch (status) {
      case CommandStatus.success:
        return 'Success';
      case CommandStatus.error:
        return 'Error';
      case CommandStatus.timeout:
        return 'Timeout';
      case CommandStatus.cancelled:
        return 'Cancelled';
      case CommandStatus.partial:
        return 'Partial';
    }
  }

  /// Escape CSV field
  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  @override
  String toString() {
    return 'LogEntry(id: $id, command: $command, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogEntry &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.command == command;
  }

  @override
  int get hashCode {
    return id.hashCode ^ timestamp.hashCode ^ command.hashCode;
  }
}
