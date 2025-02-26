import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:a_terminal/utils/debug.dart';
import 'package:a_terminal/utils/manage.dart';
import 'package:a_terminal/utils/telnet/client.dart';
import 'package:a_terminal/utils/telnet/data.dart';
import 'package:a_terminal/utils/telnet/session.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

Pty createPtyClient(String executable, Terminal terminal) {
  final pty = Pty.start(
    executable,
    columns: terminal.viewWidth,
    rows: terminal.viewHeight,
  );

  terminal.onOutput = (data) {
    pty.write(utf8.encode(data));
  };
  terminal.onResize = (w, h, pw, ph) {
    pty.resize(h, w);
  };

  pty.output
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .listen(terminal.write);
  pty.exitCode.then((code) {
    terminal.write('The process exited with exit code: $code.\r\n');
  });

  return pty;
}

final Map<String, SSHClient> sshClients = {};

// TODO: support more authentication
Future<SSHSession?> createSSHClient(
  String host,
  int port,
  String username,
  String password,
  Terminal terminal,
) async {
  terminal.write('Connecting $host...\r\n');

  try {
    final client = sshClients['$host:$port'] ??= SSHClient(
      await SSHSocket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
      ),
      username: username,
      onPasswordRequest: () => password,
    );
    final session = await client.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    terminal.onResize = (w, h, pw, ph) {
      session.resizeTerminal(w, h, pw, ph);
    };
    terminal.onOutput = (data) {
      logger.d(utf8.encode(data));
      session.write(utf8.encode(data));
    };

    session.stdout
        .cast<List<int>>()
        .transform(utf8.decoder)
        .listen(terminal.write);
    session.stderr
        .cast<List<int>>()
        .transform(utf8.decoder)
        .listen(terminal.write);

    return session;
  } catch (e) {
    terminal.write('$e.\r\n');
    return null;
  }
}

Future<SftpSession> createSftpClient(
  String name,
  String host,
  int port,
  String username,
  String password,
) async {
  final client = sshClients['$host:$port'] ??= SSHClient(
    await SSHSocket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    ),
    username: username,
    onPasswordRequest: () => password,
  );
  final sftpClient = await client.sftp();
  return SftpSession(name, sftpClient, initialPath: '/home/$username');
}

final Map<String, TelnetClient> telnetClients = {};

Future<TelnetSession?> createTelnetClient(
  String host,
  int port,
  Terminal terminal, {
  String? username,
  String? password,
  void Function(String?)? printDebug,
}) async {
  terminal.write('Connecting $host...\r\n');

  try {
    final client = telnetClients['$host:$port'] ??= TelnetClient(
      host: host,
      port: port,
      printDebug: printDebug,
    );
    final session = await client.connect(
      config: TelnetConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
      username: username,
      password: password,
      timeout: const Duration(seconds: 10),
    );

    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    terminal.onResize = (w, h, pw, ph) {
      session.resizeTerminal(w, h);
    };
    terminal.onOutput = (data) {
      session.send(data);
    };

    session.stdout
        .cast<List<int>>()
        .transform(utf8.decoder)
        .listen(terminal.write);

    return session;
  } catch (e) {
    terminal.write('$e.\r\n');
    return null;
  }
}

FutureOr<List<String>> getAvailableShells() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
      return _getWindowsShells();
    case TargetPlatform.linux:
      return await _getUnixShells(['sh', 'bash']);
    case TargetPlatform.macOS:
      return await _getUnixShells(['sh', 'bash', 'zsh']);
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    default:
      return ['sh'];
  }
}

// TODO: get environments
List<String> _getWindowsShells() {
  final env = Platform.environment['Path'];
  final List<String> extra = [];
  if (env != null && env.toLowerCase().contains('bash')) {
    extra.add('bash.exe');
  }
  return [
    'cmd.exe',
    'powershell.exe',
    ...extra,
  ];
}

Future<List<String>> _getUnixShells(List<String> defaults) async {
  final result = await Process.run('cat', ['/etc/shells']);
  if (result.exitCode == 0) {
    final shells = result.stdout
        .toString()
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.split('/').last)
        .toSet()
        .toList();
    return shells;
  }
  return defaults;
}
