import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AppLogic with DiagnosticableTreeMixin {
  AppLogic(this.context) {
    _initSettings();
  }

  final BuildContext context;

  final settings = Settings();
  final isWideScreen = ValueNotifier(false);

  late final List<String> shells;

  void _initSettings() async {
    shells = await getAvailableShells();
  }

  void updateScreenState(bool value) => isWideScreen.value = value;

  void dispose() async {
    await Hive.box<dynamic>(boxApp).compact();
    await Hive.box<ClientData>(boxClient).compact();
    await Hive.box<HistoryData>(boxHistory).compact();
    await Hive.close();
    isWideScreen.dispose();
    for (final client in sshClients.values) {
      client.close();
    }
    sshClients.clear();
    telnetClients.clear();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty(boxApp, settings));
    properties.add(DiagnosticsProperty('shells', shells));
    super.debugFillProperties(properties);
  }

  @override
  String toStringShort() {
    return 'AppLogic(settings: $settings,'
        ' shells: $shells)';
  }
}
