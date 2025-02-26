import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

enum DirItemType {
  dir,
  link,
  file,
  unknown;

  static DirItemType fromSftpFileType(SftpFileType? fileType) {
    switch (fileType) {
      case SftpFileType.directory:
        return DirItemType.dir;
      case SftpFileType.regularFile:
        return DirItemType.file;
      case SftpFileType.symbolicLink:
        return DirItemType.link;
      case SftpFileType.unknown:
      case SftpFileType.blockDevice:
      case SftpFileType.characterDevice:
      case SftpFileType.pipe:
      case SftpFileType.socket:
      case SftpFileType.whiteout:
      case _:
        return DirItemType.unknown;
    }
  }

  static DirItemType fromFSEntityType(FileSystemEntityType fileType) {
    switch (fileType) {
      case FileSystemEntityType.directory:
        return DirItemType.dir;
      case FileSystemEntityType.file:
        return DirItemType.file;
      case FileSystemEntityType.link:
        return DirItemType.link;
      case FileSystemEntityType.notFound:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
      case _:
        return DirItemType.unknown;
    }
  }
}

class DirItem {
  DirItem(this.name, this.type);

  final String name;
  final DirItemType type;
}

abstract class DirSession with TabKeyProvider {
  DirSession(this.name);

  final String name;
  final pathController = TextEditingController();
  final lastDirResult = ListenableList<DirItem>();
  final lastError = ValueNotifier<Object?>(null);

  String? previousPath;

  Future<void> openDir(String dirName);

  Future<String> openFile(String fileName);
  Future<void> saveFile(String fileName, Uint8List data);

  void listDir({bool force});

  @mustCallSuper
  void close() {
    pathController.dispose();
    lastDirResult.dispose();
    lastError.dispose();
    previousPath = null;
  }
}

class SftpSession extends DirSession {
  SftpSession(super.name, this.client, {required String initialPath}) {
    pathController.text = initialPath;
    listDir();
  }

  final SftpClient client;

  @override
  Future<void> openDir(String dirName) async {
    pathController.text = await _absolute(dirName);
    listDir();
  }

  // TODO: file stream
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
  void listDir({bool force = false}) {
    if (force || (pathController.text != previousPath)) {
      client.listdir(pathController.text).then((value) {
        lastDirResult.value = _pack(value, ['.']);
        previousPath = pathController.text;
      }).catchError((error) {
        lastError.value = error;
      });
    }
  }

  @override
  void close() {
    super.close();
    client.close();
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

class LocalManagerSession extends DirSession {
  LocalManagerSession(super.name, {required String initialPath}) {
    pathController.text = initialPath;
    listDir();
  }

  @override
  Future<void> openDir(String dirName) async {
    pathController.text = _absolute(dirName);
    listDir();
  }

  @override
  Future<String> openFile(String fileName) async {
    final file = File(_absolute(fileName));
    return utf8.decode(await file.readAsBytes(), allowMalformed: true);
  }

  @override
  Future<void> saveFile(String fileName, Uint8List data) async {
    final file = File(_absolute(fileName));
    await file.writeAsBytes(data);
  }

  @override
  void listDir({bool force = false}) {
    if (force || (pathController.text != previousPath)) {
      _lisDir(pathController.text, ['.']).then((value) {
        lastDirResult.value = value;
        previousPath = pathController.text;
      }).catchError((error) {
        lastError.value = error;
      });
    }
  }

  Future<List<DirItem>> _lisDir(
    String path, [
    List<String> skip = const [],
  ]) async {
    final result = <DirItem>[];
    result.add(DirItem(
      '..',
      DirItemType.fromFSEntityType(FileSystemEntityType.directory),
    ));
    await for (final item in Directory(path).list()) {
      final name = p.basename(item.path);
      if (!skip.contains(name)) {
        final stat = item.statSync();
        result.add(DirItem(
          name,
          DirItemType.fromFSEntityType(stat.type),
        ));
      }
    }
    return result;
  }

  String _absolute(String name) {
    late final String currentPath;
    if (pathController.text.endsWith('/')) {
      currentPath = '${pathController.text}$name';
    } else {
      currentPath = '${pathController.text}/$name';
    }
    return p.normalize(currentPath);
  }
}
