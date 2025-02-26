import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';

class AppLogic with DiagnosticableTreeMixin {
  AppLogic(this.context) {
    _initSettings();
    currentSettings.addListener(() {
      Hive.box<dynamic>(boxApp).put(keySettings, currentSettings.value);
    });
  }

  final BuildContext context;

  final currentSettings = ValueNotifier(
    SettingsData(
      themeMode: ThemeMode.system,
      useDynamicColor: defaultTargetPlatform.supportsAccentColor ? true : false,
      color: Colors.lightBlue,
      terminalMaxLines: 1000,
    ),
  );
  final isWideScreen = ValueNotifier(false);

  late final List<String> shells;

  void _initSettings() async {
    final appBox = Hive.box<dynamic>(boxApp);
    if (appBox.containsKey(keySettings)) {
      currentSettings.value = appBox.get(keySettings) as SettingsData;
    }
    shells = await getAvailableShells();
    await GoogleFonts.pendingFonts([
      GoogleFonts.notoSansSc(),
    ]);
  }

  void updateScreenState(bool value) => isWideScreen.value = value;

  void dispose() async {
    await Hive.box<dynamic>(boxApp).compact();
    await Hive.box<ClientData>(boxClient).compact();
    await Hive.close();
    currentSettings.dispose();
    isWideScreen.dispose();
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
