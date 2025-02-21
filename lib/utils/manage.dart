import 'dart:io';

import 'package:a_terminal/utils/listenable.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

enum DirItemType {
  dir,
  link,
  file,
  unknown;

  static DirItemType fromSftpFileType(SftpFileType? sftpType) {
    switch (sftpType) {
      case null:
      case SftpFileType.unknown:
      case SftpFileType.blockDevice:
      case SftpFileType.characterDevice:
      case SftpFileType.pipe:
      case SftpFileType.socket:
      case SftpFileType.whiteout:
        return DirItemType.unknown;
      case SftpFileType.regularFile:
        return DirItemType.file;
      case SftpFileType.directory:
        return DirItemType.dir;
      case SftpFileType.symbolicLink:
        return DirItemType.link;
    }
  }
}

class DirItem {
  DirItem(this.name, this.type);

  final String name;
  final DirItemType type;
}

abstract class DirSession {
  DirSession();

  final pathController = TextEditingController();
  final lastDirResult = ListenableList<DirItem>();
  final lastError = ValueNotifier<Object?>(null);

  Future<void> openDir(String dirName);

  Future<File> openFile(String fileName);
  Future<void> editFile(File tempFile);

  void listDir({bool force});

  @mustCallSuper
  void close() {
    pathController.dispose();
    lastDirResult.dispose();
    lastError.dispose();
  }
}

class SftpSession extends DirSession {
  SftpSession(this.client, {required String initialPath}) {
    pathController.text = initialPath;
    listDir();
  }

  final SftpClient client;

  String? previousPath;

  @override
  Future<void> openDir(String dirName) async {
    await _updatePath(dirName);
    listDir();
  }

  // TODO: file stream
  @override
  Future<File> openFile(String fileName) async {
    final remoteFile = await client.open(await _absolute(fileName));
    final tempFile = File('${Directory.systemTemp.path}/$fileName');
    await tempFile.writeAsBytes(await remoteFile.readBytes());
    remoteFile.close();
    return tempFile;
  }

  @override
  Future<void> editFile(File tempFile) async {
    final fileName = p.basename(tempFile.path);
    final remoteFile = await client.open(
      await _absolute(fileName),
      mode: SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write,
    );
    await remoteFile.writeBytes(await tempFile.readAsBytes());
    remoteFile.close();
  }

  @override
  void listDir({bool force = false}) {
    if (force || (pathController.text != previousPath)) {
      client.listdir(pathController.text).then((value) {
        lastDirResult.value = _pack(value, ['.']);
      }).catchError((error) {
        lastError.value = error;
      });
    }
  }

  @override
  void close() {
    super.close();
    previousPath = null;
    client.close();
  }

  Future<void> _updatePath(String dirName) async {
    previousPath = pathController.text;
    pathController.text = await _absolute(dirName);
  }

  List<DirItem> _pack(
    List<SftpName> source, [
    List<String> skip = const [],
  ]) {
    return source.skipWhile((e) => skip.contains(e.filename)).map((e) {
      return DirItem(e.filename, DirItemType.fromSftpFileType(e.attr.type));
    }).toList();
  }

  Future<String> _absolute(String name) {
    late final String currentPath;
    if (pathController.text.endsWith('/')) {
      currentPath = '${pathController.text}$name';
    } else {
      currentPath = '${pathController.text}/$name';
    }
    return client.absolute(currentPath);
  }
}
