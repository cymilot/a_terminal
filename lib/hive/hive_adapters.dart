import 'package:flutter/material.dart' show ThemeMode, Color;

import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/models/term.dart';

import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<ThemeMode>(),
  AdapterSpec<SettingModel>(),
  AdapterSpec<TermType>(),
  AdapterSpec<RemoteTermType>(),
  AdapterSpec<LocalTermModel>(),
  AdapterSpec<RemoteTermModel>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
