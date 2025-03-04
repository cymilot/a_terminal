import 'dart:convert';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive/hive_registrar.g.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:a_terminal/page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_theme/system_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? storedKey = await secureStorage.read(key: 'hiveEncryption');
  if (storedKey == null) {
    storedKey = generateRandomKey();
    await secureStorage.write(key: 'hiveEncryption', value: storedKey);
  }
  final key = base64Url.decode(storedKey);

  final defaultDataPath = await getApplicationSupportDirectory();
  logger.i('Hive: initialized, path: ${defaultDataPath.path}.');

  Hive.init(ctx.join(defaultDataPath.path, 'hive'));
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapters();
  await Hive.openBox<dynamic>(boxApp);
  await Hive.openBox<ClientData>(
    boxClient,
    encryptionCipher: HiveAesCipher(key),
  );
  await Hive.openBox<HistoryData>(boxHistory);

  if (defaultTargetPlatform.supportsAccentColor) {
    logger.i('SystemTheme: loading accent color.');
    SystemTheme.fallbackColor = Colors.lightBlue;
    await SystemTheme.accentColor.load();
  } else {
    logger.i('SystemTheme: not supported, fallback to default.');
  }

  runApp(const App());
}
