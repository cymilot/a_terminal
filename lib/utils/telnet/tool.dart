import 'dart:io';

import 'package:flutter/foundation.dart';

String get getDisplayLocation {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.iOS:
      return '';
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return Platform.environment['DISPLAY'] ?? '';
    case TargetPlatform.windows:
      throw UnimplementedError();
  }
}
