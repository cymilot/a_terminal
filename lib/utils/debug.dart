import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

bool get isDesktop {
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}

bool get isMobile {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return true;
    default:
      return false;
  }
}

final logger = Logger(
  printer: SimplePrinter(),
);
