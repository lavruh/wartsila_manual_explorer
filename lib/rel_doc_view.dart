import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path/path.dart' as p;
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:wartsila_manual_explorer/man_view.dart';
import 'package:wartsila_manual_explorer/related_documents_list.dart';

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
  int ch = 0;

  _update() => setState(() {});

  @override
  void initState() {
    ch = widget.relatedDocuments.value?.chapter ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: relatedDocViewPath,
        builder: (context, val, child) {
          Widget body = Container();
          String title = "Related documents:";
          Widget? leading;

          if (val == null) {
            body = RelatedDocumentsList(
              relatedDocuments: widget.relatedDocuments,
              onFileSelected: (val) => relatedDocViewPath.value = val,
            );
          } else {
            leading = IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => relatedDocViewPath.value = null,
            );
            title = p.basename(val);
            body = ManView(
                manualPath: val,
                controller: PdfViewerController(),
                textSearcher: textSearcher);
          }

          return Scaffold(
            appBar: AppBar(title: Text(title), leading: leading),
            body: body,
          );
        });
  }
}
