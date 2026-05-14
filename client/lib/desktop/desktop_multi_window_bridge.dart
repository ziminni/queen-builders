import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'window_startup_args.dart';

/// Registers native window control handlers required by desktop_multi_window.
///
/// See: https://pub.dev/packages/desktop_multi_window
Future<WindowStartupArgs> bootstrapDesktopMultiWindow() async {
  final controller = await WindowController.fromCurrentEngine();
  await controller.setWindowMethodHandler((call) async {
    switch (call.method) {
      case 'window_show':
        await windowManager.show();
        await windowManager.focus();
        return;
      case 'window_hide':
        await windowManager.hide();
        return;
      case 'window_close':
        await windowManager.close();
        return;
      default:
        throw MissingPluginException('desktop_multi_window: ${call.method}');
    }
  });
  return WindowStartupArgs.fromEngineArguments(controller.arguments);
}
