import 'package:flutter/foundation.dart';

class TelnetConfig {
  const TelnetConfig({
    this.type = 'xterm',
    this.width = 80,
    this.height = 24,
    this.speed = '9600,9600',
  });

  final String type;
  final int width;
  final int height;
  final String speed;
}

// [27,91,65] ESC[A up
// [27,91,66] ESC[B down
// [27,91,67] ESC[C right
// [27,91,68] ESC[D left

enum InputState {
  topLevel,
  seenESC,
  seenCSI,
}

class InputBuffer {
  final _buffer = <int>[];
  final _startArgs = <int>[];
  final _middleArgs = <int>[];

  var _cursor = 0;
  var _state = InputState.topLevel;

  int add(Uint8List data) {
    for (final byte in data) {
      _handleChar(byte);
    }
    return _cursor;
  }

  void clear() {
    _buffer.clear();
    _cursor = 0;
  }

  Uint8List consume() {
    final index = _buffer.indexOf(13);
    if (index == -1) {
      final result = data;
      clear();
      return result;
    } else {
      final sublist = _buffer.sublist(0, index + 1);
      _buffer.removeRange(0, index + 1);
      _cursor = _cursor - (index + 1);
      return Uint8List.fromList(sublist);
    }
  }

  bool get isEmpty => _buffer.isEmpty;

  bool get isNotEmpty => _buffer.isNotEmpty;

  Uint8List get data => Uint8List.fromList(_buffer);

  int get length => _buffer.length;

  void _handleChar(int byte) {
    switch (_state) {
      case InputState.topLevel:
        if (byte == 27) {
          _state = InputState.seenESC;
        } else {
          if (_cursor != length) {
            _buffer.insert(_cursor, byte);
          } else {
            _buffer.add(byte);
          }
          _cursor = _cursor + 1;
        }
        break;
      case InputState.seenESC:
        if (byte == 27) {
          _buffer.add(byte);
          _state = InputState.topLevel;
          _cursor = _cursor + 1;
        } else {
          if (byte == 91) {
            // [
            _state = InputState.seenCSI;
          } else {
            // TODO: support more sequences
            if (kDebugMode) {
              print('Unhandled escape sequence: $byte.');
            }
            _state = InputState.topLevel;
          }
        }
        break;
      case InputState.seenCSI:
        if (48 <= byte && byte <= 63) {
          // 0–9:;<=>?
          _startArgs.add(byte);
        } else if (32 <= byte && byte <= 47) {
          // space and !"#$%&'()*+,-./
          _middleArgs.add(byte);
        } else if (64 <= byte && byte <= 126) {
          // @A–Z[\]^_`a–z{|}~
          _handleCSI(byte);
          _state = InputState.topLevel;
        } else {
          // undefined
          if (kDebugMode) {
            print('Undefined char: $byte.');
          }
          _state = InputState.topLevel;
        }
        break;
    }
  }

  void _handleCSI(int lastByte) {
    switch (lastByte) {
      case 67: // Cursor Forward
        final n = _startArgs.firstOrNull ?? 1;
        _cursor = _cursor - n;
        if (_cursor < 0) _cursor = 0;
        break;
      case 68: // Cursor Back
        final n = _startArgs.firstOrNull ?? 1;
        _cursor = _cursor + n;
        if (_cursor > length) _cursor = length;
        break;
      case _:
        if (kDebugMode) {
          print('Unhandled CSI: $lastByte.');
        }
        break;
    }
    _startArgs.clear();
    _middleArgs.clear();
  }
}

class Uint8Buffer {
  var _buffer = Uint8List(0);

  void add(Uint8List data) {
    if (_buffer.isEmpty) {
      _buffer = data;
    } else {
      final newBuffer = Uint8List(data.length + _buffer.length);
      newBuffer.setRange(0, _buffer.length, _buffer);
      newBuffer.setRange(_buffer.length, newBuffer.length, data);
      _buffer = newBuffer;
    }
  }

  void addByte(int byte) {
    if (_buffer.isEmpty) {
      _buffer = Uint8List.fromList([byte]);
    } else {
      final newBuffer = Uint8List(_buffer.length + 1);
      newBuffer.setRange(0, _buffer.length + 1, [..._buffer, byte]);
      _buffer = newBuffer;
    }
  }

  Uint8List consume([int? length]) {
    if (length == null) {
      final result = _buffer;
      _buffer = Uint8List(0);
      return result;
    } else {
      final result = Uint8List.sublistView(data, 0, length);
      _buffer = Uint8List.sublistView(data, length, data.length);
      return result;
    }
  }

  void clear() => _buffer = Uint8List(0);

  Uint8List get data => _buffer;

  Uint8List view(int start, int length) =>
      _buffer.sublist(start, start + length);

  int get length => _buffer.length;

  int get first => _buffer.first;

  Iterable<int> skip(int count) => _buffer.skip(count);

  bool get isEmpty => _buffer.isEmpty;

  bool get isNotEmpty => _buffer.isNotEmpty;

  bool contains(Object? element) => _buffer.contains(element);

  bool match(List<int> matchList, [int start = 0]) {
    var index = _buffer.indexOf(matchList.first, start);
    if (index == -1 || _buffer.length - index < matchList.length) return false;
    for (var i = 0; i < matchList.length; i++) {
      if (matchList[i] != _buffer[i + index]) {
        return match(matchList, index + 1);
      }
    }
    return true;
  }

  ByteData get byteData => ByteData.sublistView(data);

  @override
  String toString() => 'Uint8Buffer(length: $length)';
}
