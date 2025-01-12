import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:path/path.dart' as p;

class RelatedDocumentsList extends StatelessWidget {
  const RelatedDocumentsList(
      {super.key,
      required this.relatedDocuments,
      required this.onFileSelected,
      required this.filter});

  final ValueNotifier<BookmarkRef?> relatedDocuments;
  final Function(String) onFileSelected;
  final ValueNotifier<String> filter;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: relatedDocuments,
        builder: (context, val, child) {
          if (val == null) {
            return Container();
          }
          return ValueListenableBuilder(
              valueListenable: filter,
              builder: (context, f, child) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: val.relatedFilePathes
                        .where((e) => p.basename(e).contains(f))
                        .map((e) => TextButton(
                              child: Text(p.basename(e)),
                              onPressed: () => onFileSelected(e),
                            ))
                        .toList(),
                  ),
                );
              });
        });
  }
}
