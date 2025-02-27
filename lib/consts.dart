import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// 0.2 seconds duration
const kAnimationDuration = Duration(milliseconds: 200);

/// 2 seconds duration
const kBackDuration = Duration(seconds: 2);

const kModalContainerHeight = 256.0;

const uuid = Uuid();
const secureStorage = FlutterSecureStorage();

String generateRandomKey() {
  final List<int> randomBytes =
      List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(randomBytes);
}

final logger = Logger(
  printer: SimplePrinter(),
);

// box
const boxApp = 'settings';
const boxClient = 'client';
const boxHistory = 'history';
