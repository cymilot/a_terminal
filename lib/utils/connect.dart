import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    // 'cmd.exe',
    // arguments: ['/k', executable],
    columns: terminal.viewWidth,
    rows: terminal.viewHeight,
    environment: Platform.environment,
    workingDirectory: getDefaultPath,
  );

  terminal.onOutput = (data) {
    pty.write(utf8.encode(data));
  };
  terminal.onResize = (w, h, pw, ph) {
    pty.resize(h, w);
  };

  pty.output.cast<List<int>>().transform(utf8.decoder).listen(terminal.write);
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
  final initialPath = await getDefaultRemotePath(client, username);
  final sftpClient = await client.sftp();
  return SftpSession(name, sftpClient, initialPath: initialPath);
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

Future<String> getDefaultRemotePath(SSHClient client, String? name) async {
  final result = await client.run('uname -s', stdout: false);
  if (result.isNotEmpty) {
    return 'C:\\Users\\$name';
  } else {
    return '/home/$name';
  }
}

String get getDefaultPath {
  final username =
      Platform.environment['USER'] ?? Platform.environment['USERNAME'];
  if (Platform.isWindows) {
    return 'C:\\Users\\$username';
  } else {
    return '/home/$username';
  }
}

FutureOr<List<String>> getAvailableShells() async {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
      return await _getWindowsShells();
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

Future<List<String>> _getWindowsShells() async {
  final script =
      '''(Get-ChildItem 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths' | 
          ForEach-Object { 
            \$_.ToString().Replace("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\", "")
          }) -join ","''';
  final result = await Process.run('powershell.exe', ['-command', script]);
  late final List<String> shells;
  if (result.exitCode == 0) {
    shells = result.stdout.toString().split(',').where((e) {
      return e.contains('pwsh.exe') || e.contains('bash.exe');
    }).toList();
  }
  return [
    'cmd.exe',
    'powershell.exe',
    ...shells,
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
