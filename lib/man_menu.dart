import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/app_controller.dart';
import 'package:wartsila_manual_explorer/outline_menu.dart';
import 'package:wartsila_manual_explorer/search_view.dart';

class ManMenu extends StatelessWidget {
  const ManMenu({super.key, required this.controller});
  final AppController controller;

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
                    valueListenable: controller.outline,
                    builder: (context, val, child) {
                      final outline = val ?? [];
                      return OutlineMenu(
                          outline: outline, controller: controller.viewer);
                    }),
                ValueListenableBuilder(
                  valueListenable: controller.docRef,
                  builder: (context, documentRef, child) => TextSearchView(
                    textSearcher: controller.textSearcher,
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
