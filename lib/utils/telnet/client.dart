import 'dart:async';
import 'dart:io';

import 'package:a_terminal/utils/telnet/data.dart';
import 'package:a_terminal/utils/telnet/session.dart';

class TelnetClient {
  TelnetClient({
    required this.host,
    required this.port,
    this.printDebug,
  });

  final String host;
  final int port;
  final void Function(String?)? printDebug;

  Future<TelnetSession> connect({
    TelnetConfig config = const TelnetConfig(),
    Map<String, String>? environment,
    String? username,
    String? password,
    Duration? timeout,
  }) async {
    printDebug?.call('[Telnet]: Starting connection.');
    final socket = await RawSocket.connect(host, port, timeout: timeout);
    return TelnetSession(
      socket: socket,
      config: config,
      environment: environment,
      username: username,
      password: password,
      printDebug: printDebug,
    );
  }
}
