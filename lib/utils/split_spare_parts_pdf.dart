import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:wartsila_manual_explorer/utils/export_pdf.dart';

class PdfSplitter {
  final progress = ValueNotifier(0.0);
  int _pagesCount = 0;

  _calculateProgress(int currentPage) {
    if (_pagesCount == 0) return;
    progress.value = (currentPage / _pagesCount);
  }

  Future<String> splitSparePartsPdf() async {
    final files = await FilePicker.platform.pickFiles(
      dialogTitle: "Select manual file",
    );
    final inputPath = files?.paths.first;
    if (inputPath == null) return "input path is null";
    final buffer = File(inputPath).readAsBytesSync();
    final document = PdfDocument(inputBytes: buffer);

    final outputPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Output directory");
    if (outputPath == null) return "output path is null";
    final outputDir = Directory(outputPath);
    if (!outputDir.existsSync()) {
      try {
        outputDir.createSync(recursive: true);
      } catch (e) {
        return e.toString();
      }
    }

    _pagesCount = document.pages.count;
    List<String> skippedPages = [];
    ParseData current = ParseData("", "", "");
    for (int i = 0; i < _pagesCount; i++) {
      _calculateProgress(i);
      try {
        final pageNo = i + 1;
        final fields = _getKeyFields(PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i));

        if (fields.section != current.section) {
          await _extractPdf(
              document: document,
              parse: current.copyWith(),
              outputPath: outputPath);
          current = fields.addPage(pageNo);
        } else {
          current = current.addPage(pageNo);
        }
      } catch (e) {
        skippedPages.add("Page $i: $e\n");
        continue;
      }
    }
    _extractPdf(document: document, parse: current, outputPath: outputPath);

    File(p.join(outputPath, "log.txt"))
        .writeAsString("Skipped pages ${skippedPages.join(",")}");

    document.dispose();

    return "Done see log";
  }

  _extractPdf({
    required PdfDocument document,
    required ParseData parse,
    required String outputPath,
  }) async {
    if (parse.pages.isEmpty) return;
    final exportDoc =
        exportSelectedPages(original: document, pages: parse.pages);
    await File(p.join(outputPath, parse.fileName))
        .writeAsBytes(await exportDoc.save());
  }

  ParseData _getKeyFields(String text) {
    final spl = "Spare Parts List";
    final start = text.indexOf(spl) + 16;
    final end = text.indexOf("Part No.");
    final header = text
        .substring(start, end)
        .replaceAll(RegExp(r"^[\s]+$", multiLine: true), "_");
    final section = RegExp(r"\d{3}-\d{2,6}").firstMatch(text)?.group(0);
    if (section == null) throw Exception("Section not found");
    final title = RegExp(r"^([a-zA-Z\s]+)$", multiLine: true)
        .firstMatch(header)
        ?.group(0);
    final date =
        RegExp(r"\d{2}\.{1}\d{2}\.{1}\d{4}").firstMatch(header)?.group(0);

    return ParseData(
      section,
      title?.replaceAll("\n", "") ?? "",
      date?.replaceAll('.', '_') ?? "",
    );
  }
}

class ParseData {
  final String section;
  final String title;
  final String date;
  final List<int> pages;

  ParseData(this.section, this.title, this.date) : pages = [];
  ParseData._(
      {required this.section,
      required this.title,
      required this.date,
      required this.pages});

  ParseData copyWith({
    String? section,
    String? title,
    String? date,
    List<int>? pages,
  }) {
    return ParseData._(
        section: section ?? this.section,
        title: title ?? this.title,
        date: date ?? this.date,
        pages: pages ?? this.pages);
  }

  ParseData addPage(int page) {
    return ParseData._(
        section: section, title: title, date: date, pages: [...pages, page]);
  }

  String get fileName => "$section $title $date.pdf";

  @override
  String toString() => "\n$section $title $pages\n";
}
