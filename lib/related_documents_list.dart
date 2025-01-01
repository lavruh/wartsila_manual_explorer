import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/bookmark_ref.dart';
import 'package:path/path.dart' as p;

class RelatedDocumentsList extends StatelessWidget {
  const RelatedDocumentsList(
      {super.key,
      required this.relatedDocuments,
      required this.onFileSelected});

  final ValueNotifier<BookmarkRef?> relatedDocuments;
  final Function(String) onFileSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: ValueListenableBuilder(
          valueListenable: relatedDocuments,
          builder: (context, val, child) {
            if (val == null) {
              return Container();
            }
            return Wrap(
              children: val.relatedFilePathes
                  .map((e) => ActionChip(
                        label: Text(p.basename(e)),
                        onPressed: () => onFileSelected(e),
                      ))
                  .toList(),
            );
          }),
    );
  }
}
