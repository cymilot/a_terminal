import 'package:flutter/material.dart' show ThemeMode, Color;

import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/hive_object/client.dart';

import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<ThemeMode>(),
  AdapterSpec<SettingsData>(),
  AdapterSpec<ClientType>(),
  AdapterSpec<RemoteClientType>(),
  AdapterSpec<LocalClientData>(),
  AdapterSpec<RemoteClientData>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
