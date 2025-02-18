import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';

class AppLogic with DiagnosticableTreeMixin {
  AppLogic(this.context);

  final BuildContext context;

  bool _initialized = false;

  final currentSettings = ListenableData(
    SettingsData(
      themeMode: ThemeMode.system,
      useSystemAccent: defaultTargetPlatform.supportsAccentColor ? true : false,
      accentColor: Colors.lightBlue,
      terminalMaxLines: 1000,
    ),
    (value) => Hive.box<dynamic>(boxApp).put(keySettings, value),
  );

  late final List<String> shells;

  Future<void> init() async {
    if (!_initialized) {
      final appBox = Hive.box<dynamic>(boxApp);
      if (appBox.containsKey(keySettings)) {
        currentSettings.value = appBox.get(keySettings) as SettingsData;
      }

      shells = await getAvailableShells();
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSansSc(),
      ]);
      _initialized = true;
    }
  }

  void dispose() async {
    await Hive.box<dynamic>(boxApp).compact();
    await Hive.box<ClientData>(boxClient).compact();
    await Hive.close();
    currentSettings.dispose();
    for (final client in sshClients.values) {
      client.close();
    }
    sshClients.clear();
    telnetClients.clear();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty(keySettings, currentSettings));
    properties.add(DiagnosticsProperty('shells', shells));
    super.debugFillProperties(properties);
  }

  @override
  String toStringShort() {
    return 'AppLogic(settings: $currentSettings,'
        ' shells: $shells)';
  }
}
