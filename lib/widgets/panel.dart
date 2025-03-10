import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

enum AppFSEntityType {
  dir,
  link,
  file,
  unknown;

  static AppFSEntityType fromFSEntityType(FileSystemEntityType fileType) {
    switch (fileType) {
      case FileSystemEntityType.directory:
        return AppFSEntityType.dir;
      case FileSystemEntityType.file:
        return AppFSEntityType.file;
      case FileSystemEntityType.link:
        return AppFSEntityType.link;
      case FileSystemEntityType.notFound:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
      case _:
        return AppFSEntityType.unknown;
    }
  }
}

class AppFSEntity {
  AppFSEntity(
    this.name,
    this.type,
    this.modifyTime,
    this.accessTime,
    this.size,
    this.mode, [
    this.extName,
  ]);

  final String name;
  final AppFSEntityType type;
  final DateTime? modifyTime;
  final DateTime? accessTime;
  final int? size;
  final int? mode;
  final String? extName;

  @override
  bool operator ==(Object other) {
    return other is AppFSEntity &&
        other.name == name &&
        other.type == type &&
        other.extName == extName;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        type,
        extName,
      ]);
}

abstract class AppFSSession extends ChangeNotifier
    implements ValueListenable<List<AppFSEntity>> {
  AppFSSession(this.name);

  final String name;

  final key = UniqueKey();
  final lastError = ValueNotifier<Object?>(null);
  final path = TextEditingController();

  final _value = <AppFSEntity>[];
  @override
  List<AppFSEntity> get value => List.unmodifiable(_value);
  bool get isNotEmpty => _value.isNotEmpty;
  void Function() get clear => _value.clear;
  void Function(Iterable<AppFSEntity>) get addAll => _value.addAll;

  FutureOr<void> updatePath([String? dirName]);

  void openDir({bool force = false});

  Future<String> openFile(String fileName);

  Future<void> saveFile(String fileName, Uint8List data);

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    _value.clear();
    lastError.dispose();
    path.dispose();
  }
}

class AppLocalFSSession extends AppFSSession {
  AppLocalFSSession(super.name, String initialPath) {
    path.text = initialPath;
    openDir();
  }

  final _perviousPath = <String>[];

  @override
  FutureOr<void> updatePath([String? dirName]) {
    _perviousPath.add(path.text);
    path.text = _absolute(dirName);
  }

  @override
  void openDir({bool force = false}) {
    if (force || (path.text != _perviousPath.lastOrNull)) {
      _openDir(path.text, ['.']).then((value) {
        if (_value.isNotEmpty) clear();
        addAll(value);
        notifyListeners();
      }).catchError((error) {
        lastError.value = error;
      });
    }
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
  void dispose() {
    super.dispose();
    _perviousPath.clear();
  }

  String _absolute(String? entityName) {
    final t = path.text;
    if (entityName != null) {
      return p.normalize(t + (t.endsWith('/') ? '' : '/') + entityName);
    } else {
      return p.normalize(t);
    }
  }

  Future<List<AppFSEntity>> _openDir(
    String path, [
    List<String> skip = const [],
  ]) async {
    final result = <AppFSEntity>[];
    final parentDir = Directory(_absolute('..')).statSync();
    result.add(AppFSEntity(
      '..',
      AppFSEntityType.fromFSEntityType(FileSystemEntityType.directory),
      parentDir.modified,
      parentDir.accessed,
      parentDir.size,
      parentDir.mode,
    ));
    await for (final item in Directory(path).list()) {
      final name = p.basename(item.path);
      if (!skip.contains(name)) {
        final stat = item.statSync();
        result.add(AppFSEntity(
          name,
          AppFSEntityType.fromFSEntityType(stat.type),
          stat.modified,
          stat.accessed,
          stat.size,
          stat.mode,
        ));
      }
    }
    return result;
  }
}

class AppFSManagerPanel extends StatelessWidget {
  const AppFSManagerPanel({
    super.key,
    required this.session,
    this.refreshTooltip,
    this.onCopyFile,
    this.onOpenFile,
    this.onError,
  });

  final AppFSSession session;
  final String? refreshTooltip;
  final void Function(String, String)? onCopyFile;
  final void Function(BuildContext, AppFSEntity, Object?)? onOpenFile;
  final void Function(dynamic)? onError;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextField(
              controller: session.path,
              onEditingComplete: () => Future.value(session.updatePath())
                  .then((_) => session.openDir()),
              decoration: InputDecoration(
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(label: Text(session.name)),
                ),
                suffixIcon: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: IconButton(
                    iconSize: 20.0,
                    onPressed: () => session.openDir(force: true),
                    icon: const Icon(Icons.refresh),
                    tooltip: refreshTooltip,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: session.lastError,
              builder: (context, error, child) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: error != null ? Center(child: Text('$error')) : child,
                );
              },
              child: ValueListenableBuilder(
                valueListenable: session,
                builder: (context, dir, _) {
                  return ListView.builder(
                    itemCount: dir.length,
                    itemBuilder: (context, index) {
                      return _buildDirEntity(context, dir[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirEntity(BuildContext context, AppFSEntity entity) {
    final icon = () {
      return switch (entity.type) {
        AppFSEntityType.dir => Icon(Icons.folder),
        AppFSEntityType.link => Icon(Icons.link),
        AppFSEntityType.file => Icon(Icons.description),
        AppFSEntityType.unknown => Icon(Icons.question_mark),
      };
    }();

    return InkWell(
      onTap: () => _onTapEntity(context, entity),
      onLongPress: () => _showOpDialog(context, entity),
      onSecondaryTap: () => _showOpDialog(context, entity),
      child: SizedBox(
        height: 48.0,
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 24.0),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12.0),
              Expanded(
                child: SizedBox(
                  height: 24.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      child: Text(entity.name),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapEntity(BuildContext context, AppFSEntity entity) async {
    switch (entity.type) {
      case AppFSEntityType.dir:
        await session.updatePath(entity.name);
        session.openDir();
        break;
      case AppFSEntityType.file:
        _showFileHandler(context, entity);
        break;
      case AppFSEntityType.link:
      case AppFSEntityType.unknown:
        break;
    }
  }

// TODO
  void _showOpDialog(BuildContext context, AppFSEntity entity) => showDialog(
        context: context,
        builder: (context) {
          final mediaSize = MediaQuery.sizeOf(context);

          return AlertDialog(
            content: SizedBox(
              width: mediaSize.width / 2,
              height: mediaSize.height / 2,
              child: ListView(
                children: [
                  ListTile(
                    title: Text('Info'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showInfoDialog(context, entity);
                    },
                  )
                ],
              ),
            ),
          );
        },
      );

  void _showFileHandler(BuildContext context, AppFSEntity entity) async {
    final result =
        await showLoadingDialog(context, session.openFile(entity.name));
    if (result != null) {
      switch (result.type) {
        case LoadingResultType.done:
        case LoadingResultType.none:
          if (context.mounted) onOpenFile?.call(context, entity, result.data);
          break;
        case LoadingResultType.error:
          onError?.call(result.data);
          break;
      }
    }
  }

// TODO
  void _showInfoDialog(BuildContext context, AppFSEntity entity) {
    final mediaSize = MediaQuery.sizeOf(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: mediaSize.width / 2,
            height: mediaSize.height / 2,
            child: ListView(
              children: [
                ListTile(
                    title: Text('modifyTime: ${entity.modifyTime.toString()}')),
                ListTile(
                    title: Text('accessTime: ${entity.accessTime.toString()}')),
                ListTile(title: Text('size: ${entity.size}')),
                ListTile(title: Text('mode: ${entity.mode}')),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<LoadingResult?> showLoadingDialog<T>(
  BuildContext context,
  Future<T> future,
) async {
  final result = await showDialog<LoadingResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => LoadingDialog(future: future),
  );
  return result;
}

enum LoadingResultType {
  done,
  error,
  none,
}

class LoadingResult {
  const LoadingResult(this.type, this.data);

  final LoadingResultType type;
  final Object? data;

  @override
  bool operator ==(Object other) {
    return other is LoadingResult && other.type == type && other.data == data;
  }

  @override
  int get hashCode => Object.hashAll([
        type,
        data,
      ]);
}

class LoadingDialog<T> extends StatelessWidget {
  const LoadingDialog({super.key, required this.future});

  final Future<T> future;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 256.0,
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                Navigator.of(context, rootNavigator: true).pop(LoadingResult(
                  LoadingResultType.done,
                  snapshot.data,
                ));
              } else {
                Navigator.of(context, rootNavigator: true).pop(LoadingResult(
                  LoadingResultType.none,
                  null,
                ));
              }
            } else if (snapshot.hasError) {
              Navigator.of(context, rootNavigator: true).pop(LoadingResult(
                LoadingResultType.error,
                snapshot.error,
              ));
            }
            return Column(
              children: [
                CircularProgressIndicator.adaptive(
                  padding: EdgeInsets.all(80.0),
                ),
                TextButton(
                  onPressed: () {
                    future.ignore();
                    Navigator.of(context).pop(LoadingResult(
                      LoadingResultType.none,
                      null,
                    ));
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
