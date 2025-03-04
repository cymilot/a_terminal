import 'dart:async';

import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/manage.dart';
import 'package:a_terminal/utils/telnet/session.dart';
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
    required this.clientKey,
    required this.clientName,
    required this.clientType,
  });

  final String clientKey;
  final String clientName;
  final ClientType clientType;
}

class LocalClientData extends ClientData {
  LocalClientData({
    required super.clientKey,
    required super.clientName,
    required this.clientShell,
  }) : super(clientType: ClientType.local);

  final String clientShell;

  @override
  bool operator ==(Object other) {
    return other is LocalClientData &&
        other.clientKey == clientKey &&
        other.clientName == clientName &&
        other.clientShell == clientShell;
  }

  @override
  int get hashCode => Object.hashAll([
        clientKey,
        clientName,
        clientShell,
      ]);

  @override
  String toString() => 'LocalClientData(clientKey: $clientKey,'
      ' clientName: $clientName,'
      ' clientShell: $clientShell)';
}

class RemoteClientData extends ClientData {
  RemoteClientData({
    required super.clientKey,
    required super.clientName,
    required this.remoteClientType,
    required this.clientHost,
    required this.clientPort,
    this.clientUser,
    this.clientPass,
  }) : super(clientType: ClientType.remote);

  final RemoteClientType remoteClientType;
  final String clientHost;
  final int clientPort;
  final String? clientUser;
  final String? clientPass;

  @override
  bool operator ==(Object other) {
    return other is RemoteClientData &&
        other.clientKey == clientKey &&
        other.clientName == clientName &&
        other.remoteClientType == remoteClientType &&
        other.clientHost == clientHost &&
        other.clientPort == clientPort &&
        other.clientUser == clientUser &&
        other.clientPass == clientPass;
  }

  @override
  int get hashCode => Object.hashAll([
        clientKey,
        clientName,
        remoteClientType,
        clientHost,
        clientPort,
        clientUser,
        clientPass,
      ]);

  @override
  String toString() => 'RemoteClientData(clientKey: $clientKey,'
      ' clientName: $clientName,'
      ' remoteClientType: $remoteClientType,'
      ' clientHost: $clientHost,'
      ' clientPort: $clientPort,'
      ' clientUser: $clientUser,'
      ' clientPass: $clientPass)';
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
  late final DirSession? _managerSession;

  (Terminal, TerminalController) createTerminal(Settings settings) {
    if (!_initTerminal) {
      _terminal = Terminal(maxLines: settings.maxLines);
      _terminalController = TerminalController();
      _createTerminalSession(settings.timeout);
    }
    return (_terminal, _terminalController);
  }

  FutureOr<DirSession?> createFileManager(Settings settings) async {
    if (clientData is LocalClientData) {
      if (!_initManagerSession) {
        _managerSession = LocalManagerSession(
          clientData.clientName,
          initialPath: defaultPath,
        );
        _initManagerSession = true;
      }
      return _managerSession;
    }
    if (clientData is RemoteClientData &&
        (clientData as RemoteClientData).remoteClientType ==
            RemoteClientType.ssh) {
      if (!_initManagerSession) {
        _managerSession = await createSftpClient(
          (clientData as RemoteClientData).clientName,
          (clientData as RemoteClientData).clientHost,
          (clientData as RemoteClientData).clientPort,
          username: (clientData as RemoteClientData).clientUser!,
          password: (clientData as RemoteClientData).clientPass!,
          timeout: settings.timeout,
          errorHandler: (e) => throw e, // FutureBuilder handles it
        );
        _initManagerSession = true;
      }
      return _managerSession;
    }
    return null;
  }

  void destroyTerminal() {
    if (_initTerminal) {
      switch (clientData.clientType) {
        case ClientType.local:
          (_terminalSession as Pty).kill();
          break;
        case ClientType.remote:
          switch ((clientData as RemoteClientData).remoteClientType) {
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
      _managerSession?.close();
      _initManagerSession = false;
    }
  }

  void closeAll() {
    destroyTerminal();
    destroyFileManager();
  }

  void _createTerminalSession(int timeout) async {
    switch (clientData.clientType) {
      case ClientType.local:
        _terminalSession = await createPtyClient(
          (clientData as LocalClientData).clientShell,
          _terminal,
        );
        break;
      case ClientType.remote:
        final remoteClientData = clientData as RemoteClientData;
        switch (remoteClientData.remoteClientType) {
          case RemoteClientType.ssh:
            _terminalSession = await createSSHClient(
              remoteClientData.clientHost,
              remoteClientData.clientPort,
              _terminal,
              username: remoteClientData.clientUser!,
              password: remoteClientData.clientPass!,
              timeout: timeout,
            );
            break;
          case RemoteClientType.telnet:
            _terminalSession = await createTelnetClient(
              remoteClientData.clientHost,
              remoteClientData.clientPort,
              _terminal,
              username: remoteClientData.clientUser,
              password: remoteClientData.clientPass,
              timeout: timeout,
            );
            break;
        }
        break;
    }
    _initTerminal = true;
  }
}
