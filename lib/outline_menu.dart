import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class OutlineMenu extends StatelessWidget {
  const OutlineMenu({
    super.key,
    required this.outline,
    required this.controller,
  });
  final List<PdfOutlineNode> outline;
  final PdfViewerController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: outline.map((e) {
        if (e.children.isEmpty) {
          return _getNode(e);
        }
        return _getChildrenTree(e, stage: 1);
      }).toList(),
    );
  }

  Widget _getChildrenTree(PdfOutlineNode e, {int? stage}) {
    final s = (stage ?? 1) + 1;
    if (e.children.isEmpty) {
      return _getNode(e, stage: s);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0 * (stage ?? 1), 0, 0, 0),
      child: ExpansionTile(
        title: Text(e.title),
        onExpansionChanged: (exp) {
          if (exp) {
            _goToPage(e.dest?.pageNumber);
          }
        },
        children: e.children.map((e) {
          return _getChildrenTree(e, stage: s);
        }).toList(),
      ),
    );
  }

  Widget _getNode(PdfOutlineNode e, {int? stage}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0 * (stage ?? 1), 0, 0, 0),
      child: ListTile(
        title: Text(e.title),
        onTap: () => _goToPage(e.dest?.pageNumber),
      ),
    );
  }

  _goToPage(int? pageNumber) {
    if (pageNumber != null) {
      controller.goToPage(pageNumber: pageNumber);
    }
  }
}
