import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:printing/printing.dart';
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:wartsila_manual_explorer/man_menu.dart';
import 'package:wartsila_manual_explorer/man_view.dart';
import 'package:wartsila_manual_explorer/rel_doc_view.dart';

class ManViewScreen extends StatefulWidget {
  const ManViewScreen({super.key});

  @override
  State<ManViewScreen> createState() => _ManViewScreenState();
}

class _ManViewScreenState extends State<ManViewScreen> {
  final controller = PdfViewerController();
  final documentRef = ValueNotifier<PdfDocumentRef?>(null);
  final outline = ValueNotifier<List<PdfOutlineNode>?>(null);
  late final textSearcher = PdfTextSearcher(controller)..addListener(_update);
  List<BookmarkRef> relatedDocumentsIndex = [];
  final relatedDocuments = ValueNotifier<BookmarkRef?>(null);
  final manualPdfFile = ValueNotifier<File?>(null);

  @override
  void initState() {
    _loadSettings();
    if (manualPdfFile.value == null) {
      _selectFile();
    }
    super.initState();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    textSearcher.removeListener(_update);
    textSearcher.dispose();
    outline.dispose();
    documentRef.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder(
            valueListenable: manualPdfFile,
            builder: (context, man, child) {
              if (man == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Row(
                children: [
                  Flexible(
                    child: ValueListenableBuilder(
                        valueListenable: outline,
                        builder: (context, val, child) {
                          if (val == null) {
                            return Container();
                          }
                          return Flexible(
                              child: ManMenu(
                            controller: controller,
                            outline: outline,
                            documentRef: documentRef,
                            textSearcher: textSearcher,
                          ));
                        }),
                  ),
                  Flexible(
                    flex: 2,
                    child: Scaffold(
                      appBar: AppBar(
                        title: Row(children: [
                          IconButton(
                              onPressed: () => controller.zoomDown(),
                              icon: Icon(Icons.zoom_out)),
                          IconButton(
                              onPressed: () => controller.zoomUp(),
                              icon: Icon(Icons.zoom_in)),
                          IconButton(
                              onPressed: () => _selectFile(),
                              icon: Icon(Icons.folder_open)),
                          IconButton(
                              onPressed: () {
                                // controller.documentRef?.
                              },
                              icon: Icon(Icons.save_alt)),
                          IconButton(
                              onPressed: () {
                                Printing.layoutPdf(
                                  onLayout: (format) {
                                    final f = manualPdfFile.value;
                                    if (f == null) {
                                      throw Exception("File is not open");
                                    }
                                    return f.readAsBytesSync();
                                  },
                                  usePrinterSettings: true,
                                );
                              },
                              icon: Icon(Icons.print)),
                        ]),
                      ),
                      body: ManView(
                        manualPath: man.path,
                        controller: controller,
                        textSearcher: textSearcher,
                        onDocumentLoaded: _updateBookmarks,
                        onPageChanged: (pageNumber) {
                          for (final i in relatedDocumentsIndex) {
                            if (i.pageStartNumber <= pageNumber) {
                              relatedDocuments.value = i;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: RelDocumentView(relatedDocuments: relatedDocuments),
                  )
                ],
              );
            }));
  }

  _updateBookmarks(PdfDocument document) async {
    final o = await document.loadOutline();
    setState(() => outline.value = o);
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
      } on Exception catch (e) {
        // print(e);
      }
    }
  }

  _selectFile() async {
    final s = await showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                decoration: InputDecoration(hintText: "Manual file path"),
                onSubmitted: (val) {
                  Navigator.of(context).pop(val);
                },
              ),
            ));
    if (s != null) {
      _openManualFile(s);
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

  _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final manualPath = prefs.getString("manualPath");
    if (manualPath != null) {
      _openManualFile(manualPath);
    }
  }
}
