import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:wartsila_manual_explorer/outline_menu.dart';
import 'package:wartsila_manual_explorer/search_view.dart';

class ManMenu extends StatelessWidget {
  const ManMenu({
    super.key,
    required this.controller,
    required this.outline,
    required this.documentRef,
    required this.textSearcher,
  });
  final PdfViewerController controller;
  final ValueNotifier<List<PdfOutlineNode>?> outline;
  final ValueNotifier<PdfDocumentRef?> documentRef;
  final PdfTextSearcher textSearcher;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [
            Tab(icon: Icon(Icons.menu_book), text: 'Tabs'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ]),
          Expanded(
            child: TabBarView(
              children: [
                ValueListenableBuilder(
                    valueListenable: outline,
                    builder: (context, val, child) {
                      final outline = val ?? [];
                      return OutlineMenu(
                          outline: outline, controller: controller);
                    }),
                ValueListenableBuilder(
                  valueListenable: documentRef,
                  builder: (context, documentRef, child) => TextSearchView(
                    textSearcher: textSearcher,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
