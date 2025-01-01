import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class ManView extends StatefulWidget {
  const ManView({
    super.key,
    required this.manualPath,
    required this.controller,
    this.onDocumentLoaded,
    required this.textSearcher,
    this.onPageChanged,
  });
  final String manualPath;
  final PdfViewerController controller;
  final Function(PdfDocument)? onDocumentLoaded;
  final PdfTextSearcher textSearcher;
  final Function(int)? onPageChanged;

  @override
  State<ManView> createState() => _ManViewState();
}

class _ManViewState extends State<ManView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfViewer.file(
        widget.manualPath,
        controller: widget.controller,
        params: PdfViewerParams(
          enableTextSelection: true,
          scaleEnabled: true,
          linkHandlerParams: PdfLinkHandlerParams(onLinkTap: (url) {
            final destPageNumber = url.dest?.pageNumber;
            if (destPageNumber != null) {
              widget.controller.goToPage(pageNumber: destPageNumber);
            }
          }),
          onPageChanged: (pageNumber) {
            if (pageNumber != null) {
              widget.onPageChanged?.call(pageNumber);
            }
          },
          pagePaintCallbacks: [
            widget.textSearcher.pageTextMatchPaintCallback,
          ],
          viewerOverlayBuilder: (context, size, handleLinkTap) => [
            // Add vertical scroll thumb on viewer's right side
            PdfViewerScrollThumb(
              controller: widget.controller,
              orientation: ScrollbarOrientation.right,
              thumbSize: const Size(40, 25),
              thumbBuilder: (context, thumbSize, pageNumber, controller) =>
                  Container(
                color: Colors.black,
                child: Center(
                  child: Text(
                    pageNumber.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            // Add horizontal scroll thumb on viewer's bottom
            // PdfViewerScrollThumb(
            //   controller: widget.controller,
            //   orientation: ScrollbarOrientation.bottom,
            //   thumbSize: const Size(80, 30),
            //   thumbBuilder: (context, thumbSize, pageNumber, controller) =>
            //       Container(color: Colors.red),
            // ),
          ],
          onViewerReady: (document, controller) async {
            widget.onDocumentLoaded?.call(document);
          },
        ),
      ),
    );
  }
}
