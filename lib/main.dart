import 'dart:convert';

import 'package:a_terminal/hive/hive_registrar.g.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/page.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:a_terminal/utils/encrypt.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? storedKey = await secureStorage.read(key: 'hiveEncryption');
  if (storedKey == null) {
    storedKey = generateRandomKey();
    await secureStorage.write(key: 'hiveEncryption', value: storedKey);
  }
  final key = base64Url.decode(storedKey);

  logger.i('Hive: initializing, path: '
      '${(await getApplicationDocumentsDirectory()).path}.');
  await Hive.initFlutter('hive');
  Hive.registerAdapters();
  await Hive.openBox<dynamic>(boxKeyApp);
  await Hive.openBox<TerminalModel>(
    boxKeyTerminal,
    encryptionCipher: HiveAesCipher(key),
  );

  if (defaultTargetPlatform.supportsAccentColor) {
    logger.i('SystemTheme: loading accent color.');
    SystemTheme.fallbackColor = Colors.lightBlue;
    await SystemTheme.accentColor.load();
  } else {
    logger.i('SystemTheme: not supported, fallback to default.');
  }

  runApp(const App());
}
