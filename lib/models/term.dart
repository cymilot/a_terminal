import 'dart:async';

import 'package:a_terminal/utils/debug.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:xterm/xterm.dart';

enum TermType {
  local,
  remote,
}

enum RemoteTermType {
  ssh,
  telnet,
}

abstract class TermModel extends HiveObject {
  TermModel({
    required this.termKey,
    required this.termName,
    required this.termType,
  });

  final String termKey;
  final String termName;
  final TermType termType;
}

class LocalTermModel extends TermModel {
  LocalTermModel({
    required super.termKey,
    required super.termName,
    required this.termShell,
  }) : super(termType: TermType.local);

  final String termShell;

  @override
  bool operator ==(Object other) {
    return other is LocalTermModel &&
        other.termKey == termKey &&
        other.termName == termName &&
        other.termShell == termShell;
  }

  @override
  int get hashCode => Object.hashAll([
        termKey,
        termName,
        termShell,
      ]);

  @override
  String toString() => 'LocalTermModel(termKey: $termKey,'
      ' termName: $termName,'
      ' termShell: $termShell)';
}

class RemoteTermModel extends TermModel {
  RemoteTermModel({
    required super.termKey,
    required super.termName,
    required this.termSubType,
    required this.termHost,
    required this.termPort,
    this.termUser,
    this.termPass,
  }) : super(termType: TermType.remote);

  final RemoteTermType termSubType;
  final String termHost;
  final int termPort;
  final String? termUser;
  final String? termPass;

  @override
  bool operator ==(Object other) {
    return other is RemoteTermModel &&
        other.termKey == termKey &&
        other.termName == termName &&
        other.termSubType == termSubType &&
        other.termHost == termHost &&
        other.termPort == termPort &&
        other.termUser == termUser &&
        other.termPass == termPass;
  }

  @override
  int get hashCode => Object.hashAll([
        termKey,
        termName,
        termSubType,
        termHost,
        termPort,
        termUser,
        termPass,
      ]);

  @override
  String toString() => 'RemoteTermModel(termKey: $termKey,'
      ' termName: $termName,'
      ' termSubType: $termSubType,'
      ' termHost: $termHost,'
      ' termPort: $termPort,'
      ' termUser: $termUser,'
      ' termPass: $termPass)';
}

class ActiveTerm {
  ActiveTerm({
    required this.key,
    required this.termData,
    required this.terminal,
    required this.onCreate,
    required this.onDestroy,
  });

  final Key key;
  final TermModel termData;
  final Terminal terminal;
  final FutureOr<dynamic> Function(Terminal) onCreate;
  final FutureOr<dynamic> Function(dynamic) onDestroy;

  bool _initialized = false;
  dynamic session;

  FutureOr<void> create() async {
    if (!_initialized) {
      session = await onCreate.call(terminal);
      _initialized = true;
      logger.i('AppConnect: Create ${termData.termType.name} terminal.');
    }
  }

  void destroy() {
    if (_initialized) {
      onDestroy.call(session);
      _initialized = false;
      logger.i('AppConnect: Destroy ${termData.termType.name} terminal.');
    }
  }
}
