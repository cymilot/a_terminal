import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<ThemeMode>(),
  AdapterSpec<ClientType>(),
  AdapterSpec<RemoteClientType>(),
  AdapterSpec<LocalClientData>(),
  AdapterSpec<RemoteClientData>(),
  AdapterSpec<HistoryData>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
