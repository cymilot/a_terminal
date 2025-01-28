import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();

String generateRandomKey() {
  final List<int> randomBytes =
      List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(randomBytes);
}
