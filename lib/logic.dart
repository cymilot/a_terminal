import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:system_theme/system_theme.dart';

class AppLogic with ChangeNotifier, DiagnosticableTreeMixin {
  AppLogic(this.context);

  final BuildContext context;

  bool _initialized = false;

  // default setting
  final currentSetting = ListenableData(
    SettingModel(
      themeMode: ThemeMode.system,
      useSystemAccent: defaultTargetPlatform.supportsAccentColor ? true : false,
      accentColor: Colors.lightBlue,
      termMaxLines: 1000,
    ),
    (value) => Hive.box<dynamic>(boxKeyApp).put(keySetting, value),
  );

  late final List<String> shells;

  Future<void> init() async {
    if (!_initialized) {
      final appBox = Hive.box<dynamic>(boxKeyApp);
      if (appBox.containsKey(keySetting)) {
        final setting = appBox.get(keySetting) as SettingModel;
        currentSetting.value = setting;
      }

      shells = await getAvailableShells();
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSansSc(),
      ]);
      _initialized = true;
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await Hive.box<dynamic>(boxKeyApp).compact();
    await Hive.box<TerminalModel>(boxKeyTerminal).compact();
    await Hive.close();
    currentSetting.dispose();
    for (final client in sshClients.values) {
      client.close();
    }
    sshClients.clear();
    telnetClients.clear();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty(keySetting, currentSetting));
    properties.add(DiagnosticsProperty('shells', shells));
    super.debugFillProperties(properties);
  }

  @override
  String toStringShort() {
    return 'AppLogic(setting: $currentSetting,'
        ' shells: $shells)';
  }
}
