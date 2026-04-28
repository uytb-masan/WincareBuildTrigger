import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1100, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Color(0xFF141422),
    titleBarStyle: TitleBarStyle.normal,
    title: 'WincareBuilder',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const WincareBuildApp());
}
