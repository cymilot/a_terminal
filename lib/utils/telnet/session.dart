import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:a_terminal/utils/telnet/data.dart';
import 'package:a_terminal/utils/telnet/symbol.dart';
import 'package:a_terminal/utils/telnet/tool.dart';
import 'package:flutter/foundation.dart';

const _maximumReadBytes = 1000;

class TelnetSession {
  TelnetSession({
    required RawSocket socket,
    required TelnetConfig config,
    Map<String, String>? environment,
    String? username,
    String? password,
    void Function(String?)? printDebug,
  })  : _socket = socket,
        _config = config,
        // _environment = environment,
        _username = username,
        _password = password,
        _printDebug = printDebug {
    _init();
  }

  final RawSocket _socket;
  final TelnetConfig _config;
  // TODO: support environments
  // final Map<String, String>? _environment;
  final String? _username;
  final String? _password;
  final void Function(String?)? _printDebug;

  final _input = InputBuffer();
  final _output = Uint8Buffer();
  final _optionRecorder = <TelnetOption, bool>{};
  final _stdout = StreamController<Uint8List>();
  final _subnegBuffer = Uint8Buffer();
  final _initialSubneg = Completer<void>();
  final _autoAuth = Completer<void>();
  final _close = Completer<void>();

  var _state = SessionState.topLevel;

  late final StreamSubscription<RawSocketEvent> _socketSubscription;
  late int _currentWidth;
  late int _currentHeight;

  Stream<Uint8List> get stdout => _stdout.stream;
  bool get isClosed => _close.isCompleted;

  void send(String data) {
    final bytes = utf8.encode(data);
    if (_optionRecorder[TelnetOption.ECHO] ?? false) {
      // TODO: The client is responsible for echo
      //? use [TerminalController]
      _input.add(bytes);
      if (bytes.contains(13)) {
        final result = _input.consume();
        _stdout.add(Uint8List.fromList([...result, 10]));
        sendBytes(result);
      }
    } else {
      sendBytes(bytes);
    }
  }

  void sendBytes(Uint8List data) {
    if (!isClosed) {
      final s = _socket.write(data);
      if (s != data.length) {
        _printDebug
            ?.call('[Telnet]: Failed to write ${data.length - s} bytes.');
      }
    }
  }

  void sendOption(TelnetCommand command, TelnetOption option) {
    _printDebug?.call('[Telnet]: Sending $command, $option to the server.');
    sendBytes(Uint8List.fromList([
      TelnetCommand.IAC.value,
      command.value,
      option.value,
    ]));
  }

  void sendSubnegotiation(TelnetOption option, List<int> args,
      [bool telIs = true]) {
    _printDebug?.call(
        '[Telnet]: Sending subnegotiation $option, $args to the server.');
    sendBytes(Uint8List.fromList([
      TelnetCommand.IAC.value,
      TelnetCommand.SB.value,
      option.value,
      if (telIs) TEL_IS,
      ...args,
      TelnetCommand.IAC.value,
      TelnetCommand.SE.value,
    ]));
  }

  void resizeTerminal(int width, int height) {
    _currentWidth = width;
    _currentHeight = height;
    if (_initialSubneg.isCompleted) {
      sendOption(TelnetCommand.WILL, TelnetOption.NAWS);
    }
  }

  void close() {
    _printDebug?.call('[Telnet]: Connection closed.');
    if (isClosed) return;
    _stdout.close();
    _socketSubscription.cancel();
    _socket.close();
    _input.clear();
    _output.clear();
    _optionRecorder.clear();
    if (!_initialSubneg.isCompleted) _initialSubneg.complete();
    if (!_autoAuth.isCompleted) _autoAuth.complete();
    _close.complete();
  }

  void _init() {
    _currentWidth = _config.width;
    _currentHeight = _config.height;
    _socketSubscription = _socket.listen(
      _handleEvent,
      onDone: _handleDone,
      onError: _handleError,
    );
    _printDebug?.call('[Telnet]: Socket Initialized.');
  }

  void _handleEvent(RawSocketEvent event) {
    switch (event) {
      case RawSocketEvent.closed:
        close();
        break;
      case RawSocketEvent.read:
        final data = _socket.read(_maximumReadBytes);
        if (data != null) _handleData(data);
        break;
      case RawSocketEvent.readClosed:
        close();
        break;
      case RawSocketEvent.write:
        _printDebug?.call('[Telnet]: Ready to write.');
        break;
    }
  }

  void _handleDone() {
    _printDebug?.call('[Telnet]: Done.');
  }

  void _handleError(Object error) {
    throw Exception(error);
  }

  void _handleData(Uint8List data) {
    _printDebug?.call('[Telnet]: Raw message[${data.length}]: $data.');
    for (final byte in data) {
      switch (_state) {
        case SessionState.topLevel:
          if (byte == TelnetCommand.IAC.value) {
            _state = SessionState.seenIAC;
          } else {
            _output.addByte(byte);
          }
          break;
        case SessionState.seenIAC:
          final c = TelnetCommand.fromInt(byte);
          switch (c) {
            case TelnetCommand.DO:
              _state = SessionState.seenDO;
              break;
            case TelnetCommand.DONT:
              _state = SessionState.seenDONT;
              break;
            case TelnetCommand.WILL:
              _state = SessionState.seenWILL;
              break;
            case TelnetCommand.WONT:
              _state = SessionState.seenWONT;
              break;
            case TelnetCommand.SB:
              _state = SessionState.seenSB;
              break;
            case TelnetCommand.DM:
              // TODO: handle DM
              _printDebug?.call('[TSession]: TODO DM.');
              _state = SessionState.topLevel;
              break;
            case _:
              if (c == TelnetCommand.IAC) {
                _output.addByte(byte);
              }
              _state = SessionState.topLevel;
              break;
          }
          break;
        case SessionState.seenDO:
          _handleOption(TelnetCommand.DO, TelnetOption.fromInt(byte));
          _state = SessionState.topLevel;
          break;
        case SessionState.seenDONT:
          _handleOption(TelnetCommand.DONT, TelnetOption.fromInt(byte));
          _state = SessionState.topLevel;
          break;
        case SessionState.seenWILL:
          _handleOption(TelnetCommand.WILL, TelnetOption.fromInt(byte));
          _state = SessionState.topLevel;
          break;
        case SessionState.seenWONT:
          _handleOption(TelnetCommand.WONT, TelnetOption.fromInt(byte));
          _state = SessionState.topLevel;
          break;
        case SessionState.seenSB:
          _subnegBuffer.clear();
          _subnegBuffer.addByte(byte);
          _state = SessionState.subnegGOT;
          break;
        case SessionState.subnegGOT:
          if (byte == TelnetCommand.IAC.value) {
            _state = SessionState.subnegIAC;
          } else {
            _subnegBuffer.addByte(byte);
          }
        case SessionState.subnegIAC:
          if (byte != TelnetCommand.SE.value) {
            _subnegBuffer.addByte(byte);
            _state = SessionState.subnegGOT;
          } else {
            _handleSubneg();
            _state = SessionState.topLevel;
          }
          break;
      }
    }
    if (_output.isNotEmpty) {
      if (!_initialSubneg.isCompleted) _initialSubneg.complete();
      _handleAuth();
      _stdout.add(_output.data);
      if ((_optionRecorder[TelnetOption.ECHO] ?? false) && _input.isNotEmpty) {
        _stdout.add(_input.consume());
      }
      _output.clear();
    }
  }

  void _handleOption(TelnetCommand command, TelnetOption? option) {
    if (option == null) return; // invalid option
    _printDebug?.call('[Telnet]: Handling server reply: $command, $option.');
    if (command == TelnetCommand.DO) {
      switch (option) {
        case TelnetOption.ECHO:
          _optionRecorder[TelnetOption.ECHO] = true;
          sendOption(TelnetCommand.WILL, option);
          break;
        case TelnetOption.NAWS:
          if (!_initialSubneg.isCompleted) {
            sendOption(TelnetCommand.WILL, option);
          }
          _handleResize();
          break;
        case TelnetOption.TTYPE:
        case TelnetOption.TSPEED:
        // TODO: support remote flow control
        // case TOption.RFC:
        case TelnetOption.XDISL:
          sendOption(TelnetCommand.WILL, option);
          break;
        // case TOption.OLDENV:
        // case TOption.NEWENV:
        case _:
          sendOption(TelnetCommand.WONT, option);
          break;
      }
    } else if (command == TelnetCommand.DONT) {
      switch (option) {
        case TelnetOption.ECHO:
          _optionRecorder[TelnetOption.ECHO] = false;
          sendOption(TelnetCommand.WONT, option);
          break;
        case _:
          _printDebug
              ?.call('[Telnet]: Unhandled server reply: $command, $option.');
          break;
      }
    } else if (command == TelnetCommand.WILL) {
      switch (option) {
        case TelnetOption.SGA:
          sendOption(TelnetCommand.DO, option);
          break;
        case TelnetOption.STATUS:
          sendOption(TelnetCommand.DO, option);
          sendSubnegotiation(
            option,
            [
              ...utf8.encode(_config.type),
              NUL,
              if (_optionRecorder[TelnetOption.ECHO] ?? false)
                ...utf8.encode('ON')
              else
                ...utf8.encode('OFF'),
              NUL,
            ],
            false,
          );
          break;
        case _:
          _printDebug
              ?.call('[Telnet]: Unhandled server reply: $command, $option.');
          break;
      }
    } else if (command == TelnetCommand.WONT) {
      switch (option) {
        case _:
          _printDebug
              ?.call('[Telnet]: Unhandled server reply: $command, $option.');
          break;
      }
    }
  }

  void _handleSubneg() {
    final option = TelnetOption.fromInt(_subnegBuffer.first);
    if (option == null) return;
    _printDebug?.call('[Telnet]: Handling server subnegotiation: $option.');
    final temp = _subnegBuffer.skip(1).toList();
    switch (option) {
      case TelnetOption.TTYPE:
        if (temp.length == 1 && temp[0] == TEL_SEND) {
          sendSubnegotiation(TelnetOption.TTYPE, utf8.encode(_config.type));
          _subnegBuffer.clear();
        } else {
          _printDebug?.call('[Telnet]: The data in the buffer is to long.');
        }
        break;
      case TelnetOption.TSPEED:
        if (temp.length == 1 && temp[0] == TEL_SEND) {
          sendSubnegotiation(TelnetOption.TSPEED, utf8.encode(_config.speed));
          _subnegBuffer.clear();
        } else {
          _printDebug?.call('[Telnet]: The data in the buffer is to long.');
        }
        break;
      // case TOption.RFC:
      case TelnetOption.XDISL:
        if (temp.length == 1 && temp[0] == TEL_SEND) {
          sendSubnegotiation(TelnetOption.XDISL,
              utf8.encode('${_socket.address.host}$getDisplayLocation'));
          _subnegBuffer.clear();
        } else {
          _printDebug?.call('[Telnet]: The data in the buffer is to long.');
        }
        break;
      // case TOption.OLDENV:
      // case TOption.NEWENV:
      case _:
        _printDebug
            ?.call('[Telnet]: Unhandled server subnegotiation: $option.');
        break;
    }
  }

  void _handleResize() {
    final widthHighByte = (_currentWidth >> 8) & 0xFF;
    final widthLowByte = _currentWidth & 0xFF;
    final heightHighByte = (_currentHeight >> 8) & 0xFF;
    final heightLowByte = _currentHeight & 0xFF;
    sendSubnegotiation(
      TelnetOption.NAWS,
      [
        widthHighByte,
        if (widthHighByte == 0xFF) 0xFF,
        widthLowByte,
        if (widthLowByte == 0xFF) 0xFF,
        heightHighByte,
        if (heightHighByte == 0xFF) 0xFF,
        heightLowByte,
        if (heightLowByte == 0xFF) 0xFF,
      ],
      false,
    );
  }

  void _handleAuth() {
    // 108, 111, 103, 105, 110, 58, 32
    // login:
    // 80, 97, 115, 115, 119, 111, 114, 100, 58, 32
    // Password:
    // 76, 111, 103, 105, 110, 32, 105, 110, 99, 111, 114, 114, 101, 99, 116
    // Login incorrect
    if (_autoAuth.isCompleted) return;
    if (_username == null || _password == null) {
      _autoAuth.complete();
      return;
    }
    if (_username != null && _output.match([108, 111, 103, 105, 110, 58, 32])) {
      sendBytes(Uint8List.fromList([...utf8.encode(_username!), 13]));
    } else if (_password != null &&
        _output.match([80, 97, 115, 115, 119, 111, 114, 100, 58, 32])) {
      sendBytes(Uint8List.fromList([...utf8.encode(_password!), 13]));
      _autoAuth.complete();
    }
  }
}
