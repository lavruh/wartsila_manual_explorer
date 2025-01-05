import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:wartsila_manual_explorer/utils/export_pdf.dart';

class AppController {
  final viewer = PdfViewerController();
  final docRef = ValueNotifier<PdfDocumentRef?>(null);
  final manualPdfFile = ValueNotifier<File?>(null);
  final outline = ValueNotifier<List<PdfOutlineNode>?>(null);
  final relatedDocuments = ValueNotifier<BookmarkRef?>(null);
  late final textSearcher = PdfTextSearcher(viewer);

  List<BookmarkRef> relatedDocumentsIndex = [];

  String get manualPath => manualPdfFile.value!.path;

  loadSettings(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final manualPath = prefs.getString("manualPath");
    if (manualPath != null) {
      await _openManualFile(manualPath);
    }
    if (manualPdfFile.value == null && context.mounted) {
      selectFile(context);
    }
  }

  selectFile(BuildContext context) async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select manual file",
    );
    if (dir != null && context.mounted) {
      final path = await FilesystemPicker.open(
          context: context, rootDirectory: Directory(dir));
      if (path != null) await _openManualFile(path);
    }
  }

  _openManualFile(String path) async {
    final f = File(path);
    if (f.existsSync()) {
      manualPdfFile.value = f;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("manualPath", path);
    }
  }

  updateBookmarks(PdfDocument document) async {
    final o = await document.loadOutline();
    outline.value = o;

    final baseDir = p.dirname(manualPdfFile.value!.path);
    final refDocsDirPath = p.join(baseDir, "service letters");
    for (final i in o) {
      try {
        final relatedDoc = BookmarkRef.getRef(
          name: i.title,
          pageStartNumber: i.dest?.pageNumber ?? 0,
          baseDirPath: refDocsDirPath,
        );
        relatedDocumentsIndex.add(relatedDoc);
      } on Exception catch (_) {
        // print(e);
      }
    }
  }

  dispose() {
    docRef.dispose();
    outline.dispose();
    textSearcher.dispose();
  }

  updateRelatedDocuments(pageNumber) {
    for (final i in relatedDocumentsIndex) {
      if (i.pageStartNumber <= pageNumber) {
        relatedDocuments.value = i;
      }
    }
  }

  exportPages(BuildContext context) {
    final originalManual = manualPdfFile.value;
    if (originalManual == null) return;
    exportPdf(originalManual: originalManual, context: context);
  }
}
