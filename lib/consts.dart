import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

const kAnimationDuration = Durations.short4;
const kBackDuration = Duration(seconds: 2);

const kInputWidth = 96.0;
const kSelectionWidth = 128.0;
const kSelectionHeight = 40.0;
const kModalContainerHeight = 256.0;
const kDialogWidth = 384.0;
const kDialogHeight = 384.0;

const boxApp = 'settings';
const boxClient = 'client';
const boxHistory = 'history';

const uuidGenerator = Uuid();
const secureStorage = FlutterSecureStorage();

final ctx = Context();
final logger = Logger(
  printer: SimplePrinter(),
);

String generateRandomKey() {
  final randomBytes =
      List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(randomBytes);
}

void doneToast(dynamic message) => toastification.show(
      type: ToastificationType.success,
      autoCloseDuration: kBackDuration,
      animationDuration: kAnimationDuration,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      title: Text('$message'),
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.minimal,
    );

void errorToast(dynamic message) => toastification.show(
      type: ToastificationType.error,
      autoCloseDuration: kBackDuration,
      animationDuration: kAnimationDuration,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      title: Text('$message'),
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.minimal,
    );

Widget switcherLayout(AlignmentGeometry a, Widget? c, List<Widget> p) {
  return Stack(
    alignment: a,
    children: [
      ...p,
      if (c != null) c,
    ],
  );
}
