import 'dart:async';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/telnet/session.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:xterm/xterm.dart';

enum ClientType {
  local,
  remote,
}

enum RemoteClientType {
  ssh,
  telnet,
}

abstract class ClientData extends HiveObject {
  ClientData({
    required this.uuid,
    required this.name,
    required this.type,
  });

  final String uuid;
  final String name;
  final ClientType type;
}

class LocalClientData extends ClientData {
  LocalClientData({
    required super.uuid,
    required super.name,
    required this.shell,
  }) : super(type: ClientType.local);

  final String shell;

  @override
  bool operator ==(Object other) {
    return other is LocalClientData &&
        other.uuid == uuid &&
        other.name == name &&
        other.shell == shell;
  }

  @override
  int get hashCode => Object.hashAll([
        uuid,
        name,
        shell,
      ]);

  @override
  String toString() => '''
LocalClientData(
  uuid: $uuid,
  name: $name,
  shell: $shell,
)''';
}

class RemoteClientData extends ClientData {
  RemoteClientData({
    required super.uuid,
    required super.name,
    required this.rType,
    required this.host,
    required this.port,
    this.user,
    this.pass,
  }) : super(type: ClientType.remote);

  final RemoteClientType rType;
  final String host;
  final int port;
  final String? user;
  final String? pass;

  @override
  bool operator ==(Object other) {
    return other is RemoteClientData &&
        other.uuid == uuid &&
        other.name == name &&
        other.rType == rType &&
        other.host == host &&
        other.port == port &&
        other.user == user &&
        other.pass == pass;
  }

  @override
  int get hashCode => Object.hashAll([
        uuid,
        name,
        rType,
        host,
        port,
        user,
        pass,
      ]);

  @override
  String toString() => '''
RemoteClientData(
  uuid: $uuid,
  name: $name,
  remoteClientType: $rType,
  host: $host,
  port: $port,
  user: $user,
  pass: $pass,
)''';
}

class ActivatedClient with TabKeyProvider {
  ActivatedClient(this.clientData, this.defaultPath);

  final ClientData clientData;
  final String defaultPath;

  bool _initTerminal = false;
  late final dynamic _terminalSession;
  late final Terminal _terminal;
  late final TerminalController _terminalController;

  bool _initManagerSession = false;
  late final AppFSSession? _managerSession;

  (Terminal, TerminalController) createTerminal(Settings settings) {
    if (!_initTerminal) {
      _terminal = Terminal(maxLines: settings.maxLines);
      _terminalController = TerminalController();
      _createTerminalSession(settings.timeout);
    }
    return (_terminal, _terminalController);
  }

  FutureOr<AppFSSession?> createFileManager(Settings settings) async {
    if (clientData is LocalClientData) {
      if (!_initManagerSession) {
        _managerSession = AppLocalFSSession(
          clientData.name,
          defaultPath,
        );
        _initManagerSession = true;
      }
      return _managerSession;
    }
    if (clientData is RemoteClientData &&
        (clientData as RemoteClientData).rType == RemoteClientType.ssh) {
      if (!_initManagerSession) {
        _managerSession = await createSftpClient(
          (clientData as RemoteClientData).name,
          (clientData as RemoteClientData).host,
          (clientData as RemoteClientData).port,
          username: (clientData as RemoteClientData).user!,
          password: (clientData as RemoteClientData).pass!,
          timeout: settings.timeout,
          errorHandler: (e) => errorToast(e),
        );
        _initManagerSession = true;
      }
      return _managerSession;
    }
    return null;
  }

  void destroyTerminal() {
    if (_initTerminal) {
      switch (clientData.type) {
        case ClientType.local:
          (_terminalSession as Pty).kill();
          break;
        case ClientType.remote:
          switch ((clientData as RemoteClientData).rType) {
            case RemoteClientType.ssh:
              (_terminalSession as SSHSession?)?.close();
              break;
            case RemoteClientType.telnet:
              (_terminalSession as TelnetSession).close();
              break;
          }
          break;
      }
      _terminal.buffer.clear();
      _terminalController.dispose();
      _initTerminal = false;
    }
  }

  void destroyFileManager() {
    if (_initManagerSession) {
      _managerSession?.dispose();
      _initManagerSession = false;
    }
  }

  void closeAll() {
    destroyTerminal();
    destroyFileManager();
  }

  void _createTerminalSession(int timeout) async {
    switch (clientData.type) {
      case ClientType.local:
        _terminalSession = await createPtyClient(
          (clientData as LocalClientData).shell,
          _terminal,
        );
        break;
      case ClientType.remote:
        final remoteClientData = clientData as RemoteClientData;
        switch (remoteClientData.rType) {
          case RemoteClientType.ssh:
            _terminalSession = await createSSHClient(
              remoteClientData.host,
              remoteClientData.port,
              _terminal,
              username: remoteClientData.user!,
              password: remoteClientData.pass!,
              timeout: timeout,
            );
            break;
          case RemoteClientType.telnet:
            _terminalSession = await createTelnetClient(
              remoteClientData.host,
              remoteClientData.port,
              _terminal,
              username: remoteClientData.user,
              password: remoteClientData.pass,
              timeout: timeout,
            );
            break;
        }
        break;
    }
    _initTerminal = true;
  }

  @override
  String toString() => '''
ActivatedClient(
  initTerminal: $_initTerminal,
  initManagerSession: $_initManagerSession,
)''';
}
