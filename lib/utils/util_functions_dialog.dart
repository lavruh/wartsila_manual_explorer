import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/utils/split_spare_parts_pdf.dart';

void utilFunctionsDialog(BuildContext context) {
  showAdaptiveDialog(
      context: context,
      builder: (context) {
        final out = ValueNotifier("");
        final splitter = PdfSplitter();
        final progress = splitter.progress;

        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                  valueListenable: out,
                  builder: (context, val, child) {
                    return Text(out.value);
                  }),
              ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (context, val, child) {
                    return LinearProgressIndicator(value: val);
                  }),
              TextButton(
                onPressed: () async {
                  out.value = await splitter.splitSparePartsPdf();
                  // Navigator.pop(context);
                },
                child: Text("Split spare parts file"),
              ),
            ],
          ),
        );
      });
}
