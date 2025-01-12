import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:wartsila_manual_explorer/man_view.dart';
import 'package:wartsila_manual_explorer/related_documents_list.dart';
import 'package:wartsila_manual_explorer/utils/export_pdf.dart';

class RelDocumentView extends StatefulWidget {
  const RelDocumentView({
    super.key,
    required this.relatedDocuments,
  });

  final ValueNotifier<BookmarkRef?> relatedDocuments;

  @override
  State<RelDocumentView> createState() => _RelDocumentViewState();
}

class _RelDocumentViewState extends State<RelDocumentView> {
  final controller = PdfViewerController();
  late final textSearcher = PdfTextSearcher(controller)..addListener(_update);
  final relatedDocViewPath = ValueNotifier<String?>(null);
  final documentsFilter = ValueNotifier<String>("");
  int ch = 0;
  double scale = 0.2;

  _update() => setState(() {});

  @override
  void initState() {
    ch = widget.relatedDocuments.value?.chapter ?? 0;
    if (Platform.isAndroid) {
      scale = 0.5;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: relatedDocViewPath,
        builder: (context, val, child) {
          Widget body = Container();
          String title = "Related docs:";
          Widget? leading;
          List<Widget> actions = [];

          if (val == null) {
            actions = [
              SizedBox(
                width: MediaQuery.of(context).size.width * scale,
                child: TextField(
                  decoration: InputDecoration(labelText: "Search"),
                  onChanged: (val) => documentsFilter.value = val,
                ),
              )
            ];
            body = RelatedDocumentsList(
              relatedDocuments: widget.relatedDocuments,
              onFileSelected: (val) => relatedDocViewPath.value = val,
              filter: documentsFilter,
            );
          } else {
            leading = IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                textSearcher.resetTextSearch();
                relatedDocViewPath.value = null;
              },
            );
            title = "";
            actions.add(SizedBox(
              width: MediaQuery.of(context).size.width * scale,
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Search",
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: (textSearcher.currentIndex ?? 0) <
                                  textSearcher.matches.length
                              ? () async {
                                  await textSearcher.goToNextMatch();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 20,
                        ),
                        IconButton(
                          onPressed: (textSearcher.currentIndex ?? 0) <
                                  textSearcher.matches.length
                              ? () async {
                                  await textSearcher.goToPrevMatch();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_upward),
                          iconSize: 20,
                        ),
                      ],
                    )),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    textSearcher.startTextSearch(val);
                  }
                },
              ),
            ));
            actions.add(
              IconButton(
                  onPressed: () {
                    final export = File(val);
                    exportPdf(originalManual: export, context: context);
                  },
                  icon: Icon(Icons.save_alt)),
            );
            body = ManView(
                manualPath: val,
                controller: controller,
                textSearcher: textSearcher);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: leading,
              actions: actions,
            ),
            body: body,
          );
        });
  }
}
