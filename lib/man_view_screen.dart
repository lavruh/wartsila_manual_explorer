import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/app_controller.dart';
import 'package:wartsila_manual_explorer/man_menu.dart';
import 'package:wartsila_manual_explorer/man_view.dart';
import 'package:wartsila_manual_explorer/rel_doc_view.dart';
import 'package:wartsila_manual_explorer/utils/util_functions_dialog.dart';

class ManViewScreen extends StatefulWidget {
  const ManViewScreen({super.key, required this.app});
  final AppController app;

  @override
  State<ManViewScreen> createState() => _ManViewScreenState();
}

class _ManViewScreenState extends State<ManViewScreen> {
  late final AppController controller = widget.app;

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    controller.textSearcher.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    controller.textSearcher.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildBookmarks(),
        _buildManView(controller.manualPath),
        _buildRelatedDocuments(),
      ],
    );
  }

  Widget _buildBookmarks() {
    return Flexible(
      child: ValueListenableBuilder(
          valueListenable: controller.outline,
          builder: (context, val, child) {
            if (val == null) {
              return Container();
            }
            return Flexible(child: ManMenu(controller: controller));
          }),
    );
  }

  Widget _buildManView(String manPath) {
    return Flexible(
      flex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            IconButton(
                onPressed: () => controller.viewer.zoomDown(),
                icon: Icon(Icons.zoom_out)),
            IconButton(
                onPressed: () => controller.viewer.zoomUp(),
                icon: Icon(Icons.zoom_in)),
            IconButton(
                onPressed: () => controller.selectFile(context),
                icon: Icon(Icons.folder_open)),
            IconButton(
                onPressed: () => controller.exportPages(context),
                icon: Icon(Icons.save_alt)),
            if (Platform.isLinux)
              IconButton(
                  onPressed: () => utilFunctionsDialog(context),
                  icon: Icon(Icons.play_arrow)),
          ]),
        ),
        body: ManView(
          manualPath: manPath,
          controller: controller.viewer,
          textSearcher: controller.textSearcher,
          onDocumentLoaded: (val) {
            controller.updateBookmarks(val);
            setState(() {});
          },
          onPageChanged: controller.updateRelatedDocuments,
        ),
      ),
    );
  }

  Widget _buildRelatedDocuments() {
    return Flexible(
      flex: 2,
      child: RelDocumentView(relatedDocuments: controller.relatedDocuments),
    );
  }
}
