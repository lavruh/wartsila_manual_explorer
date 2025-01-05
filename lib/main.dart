import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wartsila_manual_explorer/app_controller.dart';
import 'package:wartsila_manual_explorer/man_view_screen.dart';
import 'package:wartsila_manual_explorer/man_view_screen_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = AppController();

  @override
  void initState() {
    controller.loadSettings(context);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wartsila Manual Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: Scaffold(
          body: ValueListenableBuilder(
              valueListenable: controller.manualPdfFile,
              builder: (context, man, child) {
                if (man == null) {
                  return Center(
                    child: IconButton(
                        onPressed: () => controller.selectFile(context),
                        icon: Icon(Icons.folder_open)),
                  );
                }
                if (Platform.isAndroid) {
                  return ManViewScreenAndroid(app: controller);
                }
                return ManViewScreen(app: controller);
              })),
    );
  }
}
