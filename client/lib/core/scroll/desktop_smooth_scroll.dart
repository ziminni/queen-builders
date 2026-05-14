import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Mouse/trackpad drag scrolling and stable clamp physics on desktop dialogs and lists.
class DesktopSmoothScrollBehavior extends MaterialScrollBehavior {
  const DesktopSmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    );
  }
}
