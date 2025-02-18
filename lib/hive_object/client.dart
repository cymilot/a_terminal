import 'dart:async';

import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/telnet/session.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
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

class ActivatedClient {
  ActivatedClient({
    required this.key,
    required this.clientData,
  });

  /// for tab
  final Key key;
  final ClientData clientData;

  bool _initSftp = false;
  late final SftpManager _sftp;

  bool _initTerminal = false;
  dynamic _terminalSession;
  late final Terminal _terminal;

  Terminal createTerminal(SettingsData settings) {
    if (!_initTerminal) {
      _terminal = Terminal(maxLines: settings.terminalMaxLines);
      _createTerminalSession();
    }
    return _terminal;
  }

  void _createTerminalSession() async {
    switch (clientData.clientType) {
      case ClientType.local:
        _terminalSession = createPtyClient(
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
              remoteClientData.clientUser!,
              remoteClientData.clientPass!,
              _terminal,
            );
            break;
          case RemoteClientType.telnet:
            _terminalSession = await createTelnetClient(
              remoteClientData.clientHost,
              remoteClientData.clientPort,
              _terminal,
              username: remoteClientData.clientUser,
              password: remoteClientData.clientPass,
            );
            break;
        }
        break;
    }
    _initTerminal = true;
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
              (_terminalSession as SSHSession).close();
              break;
            case RemoteClientType.telnet:
              (_terminalSession as TelnetSession).close();
              break;
          }
          break;
      }
      _initTerminal = false;
    }
  }

  FutureOr<SftpManager?> createSftp() async {
    if (clientData is RemoteClientData &&
        (clientData as RemoteClientData).remoteClientType ==
            RemoteClientType.ssh) {
      if (!_initSftp) {
        _sftp = SftpManager(
          await createSftpClient(
            (clientData as RemoteClientData).clientHost,
            (clientData as RemoteClientData).clientPort,
            (clientData as RemoteClientData).clientUser!,
            (clientData as RemoteClientData).clientPass!,
          ),
          TextEditingController(
            text: '/home/${(clientData as RemoteClientData).clientUser}',
          ),
          ListenableList(),
        );
        _initSftp = true;
      }
      return _sftp;
    }
    return null;
  }

  void destroySftp() {
    if (_initSftp &&
        (clientData is RemoteClientData &&
            (clientData as RemoteClientData).remoteClientType ==
                RemoteClientType.ssh)) {
      _sftp.close();
      _initSftp = false;
    }
  }
}

class SftpManager {
  SftpManager(this.client, this.pathController, this.lastDirResult);

  final SftpClient client;
  final TextEditingController pathController;
  final ListenableList<SftpName> lastDirResult;

  String? previousPath;

  void listDir() async {
    if (pathController.text != previousPath) {
      lastDirResult.value = await client.listdir(pathController.text);
      previousPath = pathController.text;
    }
  }

  void close() {
    lastDirResult.dispose();
    pathController.dispose();
    previousPath = null;
    client.close();
  }
}
