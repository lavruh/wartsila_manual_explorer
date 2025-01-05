import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/app_controller.dart';
import 'package:wartsila_manual_explorer/man_menu.dart';
import 'package:wartsila_manual_explorer/man_view.dart';
import 'package:wartsila_manual_explorer/rel_doc_view.dart';

class ManViewScreenAndroid extends StatefulWidget {
  const ManViewScreenAndroid({super.key, required this.app});
  final AppController app;

  @override
  State<ManViewScreenAndroid> createState() => _ManViewScreenState();
}

class _ManViewScreenState extends State<ManViewScreenAndroid> {
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
    return PageView(
      children: [
        _buildManView(controller.manualPath),
        _buildRelatedDocuments(),
      ],
    );
  }

  Widget _buildBookmarks() {
    return ValueListenableBuilder(
        valueListenable: controller.outline,
        builder: (context, val, child) {
          if (val == null) {
            return Container();
          }
          return ManMenu(controller: controller);
        });
  }

  Widget _buildManView(String manPath) {
    return Scaffold(
      drawer: Drawer(child: _buildBookmarks()),
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
    );
  }

  Widget _buildRelatedDocuments() {
    return RelDocumentView(relatedDocuments: controller.relatedDocuments);
  }
}
