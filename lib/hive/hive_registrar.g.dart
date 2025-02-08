// Generated by Hive CE
// Do not modify
// Check in to version control

import 'package:hive_ce/hive.dart';
import 'package:a_terminal/hive/hive_adapters.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(LocalTerminalModelAdapter());
    registerAdapter(RemoteTerminalModelAdapter());
    registerAdapter(RemoteTerminalTypeAdapter());
    registerAdapter(SettingModelAdapter());
    registerAdapter(TerminalTypeAdapter());
    registerAdapter(ThemeModeAdapter());
  }
}
