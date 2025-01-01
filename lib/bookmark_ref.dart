import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class BookmarkRef {
  final String name;
  final int pageStartNumber;
  final int chapter;
  final Directory relatedDir;
  final List<String> relatedFilePathes;

  BookmarkRef._(this.name, this.pageStartNumber, this.chapter,
      this.relatedDir, this.relatedFilePathes);

  factory BookmarkRef.getRef({
    required String name,
    required int pageStartNumber,
    required String baseDirPath,
  }) {
    final chapterNumber = name.substring(0, 2);
    int ch = 0;

    try{
     ch = int.parse(chapterNumber);
    } catch (e) {
      throw Exception("Invalid chapter number: $chapterNumber");
    }
    final d = Directory(baseDirPath);
    final entity = d.listSync().firstWhereOrNull((subdir) {
      final basename = p.basename(subdir.path);
      return basename.startsWith(chapterNumber);
    });
    if (entity == null) {
      throw Exception("Directory doesn't exist for chapter: $chapterNumber");
    }
    final relatedDir = Directory(entity.path);

    List<String> relatedFilePathes = relatedDir
        .listSync()
        .map((e) => p.join(relatedDir.path, e.path))
        .toList();

    return BookmarkRef._(
        name, pageStartNumber, ch, relatedDir, relatedFilePathes);
  }
}
