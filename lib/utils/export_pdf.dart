import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<List<int>?> _inputPageNumbers(BuildContext context) async {
  return await showDialog<List<int>>(
      context: context,
      builder: (context) => AlertDialog(
            content: TextField(
              decoration: InputDecoration(hintText: "Pages"),
              onSubmitted: (val) {
                final s = val.split(",");
                List<int> pages = [];
                for (final i in s) {
                  if (i.contains("-")) {
                    final range = i.split("-");
                    final start = int.tryParse(range[0]);
                    final end = int.tryParse(range[1]);
                    if (start != null && end != null) {
                      for (int j = start; j <= end; j++) {
                        pages.add(j);
                      }
                    }
                    continue;
                  }
                  final p = int.tryParse(i);
                  if (p != null) {
                    pages.add(p);
                  }
                }
                Navigator.of(context).pop(pages);
              },
            ),
          ));
}

exportPdf({required File originalManual, required BuildContext context}) async {
  final pages = await _inputPageNumbers(context);
  if (pages != null && pages.isNotEmpty) {
    final buffer = originalManual.readAsBytesSync();
    final original = PdfDocument(inputBytes: buffer);

    final export = exportSelectedPages(original: original, pages: pages);
    final output = await FilePicker.platform.saveFile(
      dialogTitle: "Save",
      fileName: "manual.pdf",
      allowedExtensions: ["pdf"],
    );
    if (output != null) {
      File(output).writeAsBytesSync(await export.save());
    }
  }
}

PdfDocument exportSelectedPages(
    {required PdfDocument original, required List<int> pages}) {
  PdfDocument export = PdfDocument();

  export.pageSettings.setMargins(0);

  for (final pageNo in pages) {
    if (pageNo > original.pages.count || pageNo < 1) continue;

    final template = original.pages[pageNo - 1].createTemplate();
    final newPage = export.pages.add();
    newPage.graphics.drawPdfTemplate(template, Offset(0, 0));
  }
  return export;
}
