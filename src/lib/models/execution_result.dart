/// Model representing the result of executing a file or command
class ExecutionResult {
  final String stdout;
  final String stderr;
  final int? exitCode;
  final Duration duration;
  final DateTime timestamp;
  
  const ExecutionResult({
    required this.stdout,
    required this.stderr,
    this.exitCode,
    required this.duration,
    required this.timestamp,
  });
  
  /// Check if the execution resulted in an error
  bool get hasError => stderr.isNotEmpty || (exitCode != null && exitCode != 0);
  
  /// Check if the execution produced no output
  bool get isEmpty => stdout.isEmpty && stderr.isEmpty;
  
  /// Get combined output (stdout + stderr)
  String get combinedOutput {
    if (stdout.isEmpty && stderr.isEmpty) return '';
    if (stdout.isEmpty) return stderr;
    if (stderr.isEmpty) return stdout;
    return '$stdout\n--- STDERR ---\n$stderr';
  }
  
  /// Get a human-readable status description
  String get statusDescription {
    if (hasError) {
      return exitCode != null ? 'Failed (exit code: $exitCode)' : 'Failed';
    }
    return 'Success';
  }
  
  /// Create a copy with modified values
  ExecutionResult copyWith({
    String? stdout,
    String? stderr,
    int? exitCode,
    Duration? duration,
    DateTime? timestamp,
  }) {
    return ExecutionResult(
      stdout: stdout ?? this.stdout,
      stderr: stderr ?? this.stderr,
      exitCode: exitCode ?? this.exitCode,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExecutionResult &&
        other.stdout == stdout &&
        other.stderr == stderr &&
        other.exitCode == exitCode &&
        other.duration == duration &&
        other.timestamp == timestamp;
  }
  
  @override
  int get hashCode {
    return Object.hash(stdout, stderr, exitCode, duration, timestamp);
  }
  
  @override
  String toString() {
    return 'ExecutionResult(stdout: "${stdout.length} chars", stderr: "${stderr.length} chars", exitCode: $exitCode, duration: ${duration.inMilliseconds}ms)';
  }
}