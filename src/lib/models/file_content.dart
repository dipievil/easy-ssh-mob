/// Enum representing different file view modes
enum FileViewMode {
  full, // Complete file content
  head, // First lines of file
  tail, // Last lines of file
  truncated, // File truncated due to size
}

/// Model representing the content of a file read from SSH server
class FileContent {
  final String content;
  final bool isTruncated;
  final int totalLines;
  final int displayedLines;
  final FileViewMode mode;
  final int? fileSize;

  const FileContent({
    required this.content,
    required this.isTruncated,
    required this.totalLines,
    required this.displayedLines,
    required this.mode,
    this.fileSize,
  });

  /// Check if file content is empty
  bool get isEmpty => content.isEmpty;

  /// Get human-readable view mode description
  String get modeDescription {
    switch (mode) {
      case FileViewMode.full:
        return 'Complete file';
      case FileViewMode.head:
        return 'First $displayedLines lines';
      case FileViewMode.tail:
        return 'Last $displayedLines lines';
      case FileViewMode.truncated:
        return 'Truncated content';
    }
  }

  /// Get file size description
  String get fileSizeDescription {
    if (fileSize == null) return 'Unknown size';

    final size = fileSize!;
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Create a copy with modified values
  FileContent copyWith({
    String? content,
    bool? isTruncated,
    int? totalLines,
    int? displayedLines,
    FileViewMode? mode,
    int? fileSize,
  }) {
    return FileContent(
      content: content ?? this.content,
      isTruncated: isTruncated ?? this.isTruncated,
      totalLines: totalLines ?? this.totalLines,
      displayedLines: displayedLines ?? this.displayedLines,
      mode: mode ?? this.mode,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileContent &&
        other.content == content &&
        other.isTruncated == isTruncated &&
        other.totalLines == totalLines &&
        other.displayedLines == displayedLines &&
        other.mode == mode &&
        other.fileSize == fileSize;
  }

  @override
  int get hashCode {
    return Object.hash(
      content,
      isTruncated,
      totalLines,
      displayedLines,
      mode,
      fileSize,
    );
  }

  @override
  String toString() {
    return 'FileContent(mode: $mode, lines: $displayedLines/$totalLines, truncated: $isTruncated)';
  }
}
