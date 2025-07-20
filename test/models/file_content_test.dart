import 'package:flutter_test/flutter_test.dart';
import 'package:easyssh/models/file_content.dart';

void main() {
  group('FileContent', () {
    test('should create FileContent with all properties', () {
      const content = FileContent(
        content: 'Hello World',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
        fileSize: 11,
      );

      expect(content.content, 'Hello World');
      expect(content.isTruncated, false);
      expect(content.totalLines, 1);
      expect(content.displayedLines, 1);
      expect(content.mode, FileViewMode.full);
      expect(content.fileSize, 11);
    });

    test('should check if content is empty', () {
      const emptyContent = FileContent(
        content: '',
        isTruncated: false,
        totalLines: 0,
        displayedLines: 0,
        mode: FileViewMode.full,
      );

      const nonEmptyContent = FileContent(
        content: 'Hello',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      expect(emptyContent.isEmpty, true);
      expect(nonEmptyContent.isEmpty, false);
    });

    test('should provide correct mode descriptions', () {
      const fullContent = FileContent(
        content: 'test',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      const headContent = FileContent(
        content: 'test',
        isTruncated: true,
        totalLines: 100,
        displayedLines: 10,
        mode: FileViewMode.head,
      );

      const tailContent = FileContent(
        content: 'test',
        isTruncated: true,
        totalLines: 100,
        displayedLines: 10,
        mode: FileViewMode.tail,
      );

      const truncatedContent = FileContent(
        content: 'test',
        isTruncated: true,
        totalLines: 50,
        displayedLines: 50,
        mode: FileViewMode.truncated,
      );

      expect(fullContent.modeDescription, 'Complete file');
      expect(headContent.modeDescription, 'First 10 lines');
      expect(tailContent.modeDescription, 'Last 10 lines');
      expect(truncatedContent.modeDescription, 'Truncated content');
    });

    test('should format file sizes correctly', () {
      const smallFile = FileContent(
        content: 'test',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
        fileSize: 512,
      );

      const mediumFile = FileContent(
        content: 'test',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
        fileSize: 1536, // 1.5 KB
      );

      const largeFile = FileContent(
        content: 'test',
        isTruncated: true,
        totalLines: 1000,
        displayedLines: 100,
        mode: FileViewMode.head,
        fileSize: 2097152, // 2 MB
      );

      expect(smallFile.fileSizeDescription, '512 B');
      expect(mediumFile.fileSizeDescription, '1.5 KB');
      expect(largeFile.fileSizeDescription, '2.0 MB');
    });

    test('should create copy with modified values', () {
      const original = FileContent(
        content: 'original',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      final copy = original.copyWith(
        content: 'modified',
        isTruncated: true,
      );

      expect(copy.content, 'modified');
      expect(copy.isTruncated, true);
      expect(copy.totalLines, 1); // unchanged
      expect(copy.displayedLines, 1); // unchanged
      expect(copy.mode, FileViewMode.full); // unchanged
    });

    test('should implement equality correctly', () {
      const content1 = FileContent(
        content: 'test',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      const content2 = FileContent(
        content: 'test',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      const content3 = FileContent(
        content: 'different',
        isTruncated: false,
        totalLines: 1,
        displayedLines: 1,
        mode: FileViewMode.full,
      );

      expect(content1 == content2, true);
      expect(content1 == content3, false);
      expect(content1.hashCode == content2.hashCode, true);
    });
  });
}