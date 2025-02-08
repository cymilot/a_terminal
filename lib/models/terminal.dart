import 'dart:async';

import 'package:a_terminal/utils/debug.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:xterm/xterm.dart';

enum TerminalType {
  local,
  remote,
}

enum RemoteTerminalType {
  ssh,
  telnet,
}

abstract class TerminalModel extends HiveObject {
  TerminalModel({
    required this.terminalKey,
    required this.terminalName,
    required this.terminalType,
  });

  final String terminalKey;
  final String terminalName;
  final TerminalType terminalType;
}

class LocalTerminalModel extends TerminalModel {
  LocalTerminalModel({
    required super.terminalKey,
    required super.terminalName,
    required this.terminalShell,
  }) : super(terminalType: TerminalType.local);

  final String terminalShell;

  @override
  bool operator ==(Object other) {
    return other is LocalTerminalModel &&
        other.terminalKey == terminalKey &&
        other.terminalName == terminalName &&
        other.terminalShell == terminalShell;
  }

  @override
  int get hashCode => Object.hashAll([
        terminalKey,
        terminalName,
        terminalShell,
      ]);

  @override
  String toString() => 'LocalTermModel(terminalKey: $terminalKey,'
      ' terminalName: $terminalName,'
      ' terminalShell: $terminalShell)';
}

class RemoteTerminalModel extends TerminalModel {
  RemoteTerminalModel({
    required super.terminalKey,
    required super.terminalName,
    required this.terminalSubType,
    required this.terminalHost,
    required this.terminalPort,
    this.terminalUser,
    this.terminalPass,
  }) : super(terminalType: TerminalType.remote);

  final RemoteTerminalType terminalSubType;
  final String terminalHost;
  final int terminalPort;
  final String? terminalUser;
  final String? terminalPass;

  @override
  bool operator ==(Object other) {
    return other is RemoteTerminalModel &&
        other.terminalKey == terminalKey &&
        other.terminalName == terminalName &&
        other.terminalSubType == terminalSubType &&
        other.terminalHost == terminalHost &&
        other.terminalPort == terminalPort &&
        other.terminalUser == terminalUser &&
        other.terminalPass == terminalPass;
  }

  @override
  int get hashCode => Object.hashAll([
        terminalKey,
        terminalName,
        terminalSubType,
        terminalHost,
        terminalPort,
        terminalUser,
        terminalPass,
      ]);

  @override
  String toString() => 'RemoteTermModel(terminalKey: $terminalKey,'
      ' terminalName: $terminalName,'
      ' terminalSubType: $terminalSubType,'
      ' terminalHost: $terminalHost,'
      ' terminalPort: $terminalPort,'
      ' terminalUser: $terminalUser,'
      ' terminalPass: $terminalPass)';
}

class ActivatedTerminal {
  ActivatedTerminal({
    required this.key,
    required this.terminalData,
    required this.terminal,
    required this.onCreate,
    required this.onDestroy,
  });

  final Key key;
  final TerminalModel terminalData;
  final Terminal terminal;
  final FutureOr<dynamic> Function(Terminal) onCreate;
  final FutureOr<dynamic> Function(dynamic) onDestroy;

  bool _initialized = false;
  dynamic session;

  FutureOr<void> create() async {
    if (!_initialized) {
      session = await onCreate.call(terminal);
      _initialized = true;
      logger
          .i('AppConnect: Create ${terminalData.terminalType.name} terminal.');
    }
  }

  void destroy() {
    if (_initialized) {
      onDestroy.call(session);
      _initialized = false;
      logger
          .i('AppConnect: Destroy ${terminalData.terminalType.name} terminal.');
    }
  }
}
