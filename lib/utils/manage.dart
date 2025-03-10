import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:dartssh2/dartssh2.dart';

class AppSftpSession extends AppFSSession {
  AppSftpSession(super.name, this.client, String initialPath) {
    path.text = initialPath;
    openDir();
  }

  final SftpClient client;

  final _perviousPath = <String>[];

  @override
  FutureOr<void> updatePath([String? dirName]) async {
    _perviousPath.add(path.text);
    path.text = await _absolute(dirName);
  }

  @override
  void openDir({bool force = false}) {
    if (force || (path.text != _perviousPath.lastOrNull)) {
      logger.d('checked');
      client.listdir(path.text).then((value) {
        if (isNotEmpty) clear();
        addAll(_pack(value, ['.']));
        notifyListeners();
      }).catchError((error) {
        lastError.value = error;
      });
    }
  }

  @override
  Future<String> openFile(String fileName) async {
    final remoteFile = await client.open(await _absolute(fileName));
    return utf8.decode(await remoteFile.readBytes(), allowMalformed: true);
  }

  @override
  Future<void> saveFile(String fileName, Uint8List data) async {
    final remoteFile = await client.open(
      await _absolute(fileName),
      mode: SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write,
    );
    await remoteFile.writeBytes(data);
    remoteFile.close();
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
  }

  List<AppFSEntity> _pack(
    List<SftpName> source, [
    List<String> skip = const [],
  ]) {
    return source.skipWhile((e) => skip.contains(e.filename)).map((e) {
      final attr = e.attr;
      final modifyTime = attr.modifyTime != null
          ? DateTime.fromMillisecondsSinceEpoch(attr.modifyTime! * 1000)
          : null;
      final accessTime = attr.accessTime != null
          ? DateTime.fromMillisecondsSinceEpoch(attr.accessTime! * 1000)
          : null;
      return AppFSEntity(
        e.filename,
        ExAppFSEntityType.fromSftpFileType(e.attr.type),
        modifyTime,
        accessTime,
        attr.size,
        attr.mode?.value,
      );
    }).toList();
  }

  Future<String> _absolute(String? entityName) {
    final t = path.text;
    if (entityName != null) {
      return client.absolute(t + (t.endsWith('/') ? '' : '/') + entityName);
    } else {
      return client.absolute(t);
    }
  }
}
