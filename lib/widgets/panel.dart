import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

enum AppFSAttrType {
  dir,
  link,
  file,
  unknown,
  notFound;

  static AppFSAttrType fromFSEntityType(FileSystemEntityType type) {
    switch (type) {
      case FileSystemEntityType.directory:
        return AppFSAttrType.dir;
      case FileSystemEntityType.file:
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
        return AppFSAttrType.file;
      case FileSystemEntityType.link:
        return AppFSAttrType.link;
      case FileSystemEntityType.notFound:
      case _:
        return AppFSAttrType.notFound;
    }
  }
}

extension ExAppFSEntityType on AppFSAttrType {
  static AppFSAttrType fromSftpFileType(SftpFileType? fileType) {
    switch (fileType) {
      case SftpFileType.directory:
        return AppFSAttrType.dir;
      case SftpFileType.symbolicLink:
        return AppFSAttrType.link;
      case SftpFileType.blockDevice:
      case SftpFileType.characterDevice:
      case SftpFileType.pipe:
      case SftpFileType.socket:
      case SftpFileType.whiteout:
      case SftpFileType.regularFile:
        return AppFSAttrType.file;
      case SftpFileType.unknown:
        return AppFSAttrType.unknown;
      case _:
        return AppFSAttrType.notFound;
    }
  }
}

class AppFSAttr {
  AppFSAttr({
    required this.fileName,
    this.extName,
    required this.fullPath,
    required this.type,
    this.linkPath,
    this.accessTime,
    this.modifyTime,
    this.size,
    this.mode,
  });

  final String fileName;
  final String? extName;
  final String fullPath;
  final AppFSAttrType type;
  final String? linkPath;
  final DateTime? accessTime;
  final DateTime? modifyTime;
  final int? size;
  final int? mode;

  @override
  bool operator ==(Object other) {
    return other is AppFSAttr &&
        other.fileName == fileName &&
        other.type == type &&
        other.fullPath == fullPath &&
        other.accessTime == accessTime &&
        other.modifyTime == modifyTime &&
        other.size == size &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hashAll([
        fileName,
        type,
        fullPath,
        accessTime,
        modifyTime,
        size,
        mode,
      ]);
}

abstract class AppFSSession extends ChangeNotifier
    implements ValueListenable<List<AppFSAttr>> {
  AppFSSession({required this.name});

  final String name;

  final key = UniqueKey();
  final path = TextEditingController();
  final _value = <AppFSAttr>[];
  @override
  List<AppFSAttr> get value => List.unmodifiable(_value);
  set value(List<AppFSAttr> newValue) {
    _value.clear();
    _value.addAll(newValue);
    notifyListeners();
  }

  String absolute(String base, [String? extra]) {
    final s = p.separator;
    if (extra != null) {
      return p.normalize('$base${base.endsWith(s) ? '' : s}$extra');
    } else {
      return p.normalize(base);
    }
  }

  Future<void> create(
    String fullPath,
    AppFSAttrType type, {
    String? extra,
    bool recursive = false,
    bool exclusive = false,
  });

  Future<void> delete(String fullPath, {bool recursive = false});

  Future<bool> exists(String fullPath);

  Future<String?> linkTarget(String fullPath);

  void listDir() async {
    path.text = absolute(path.text);
    final result = await readDir(path.text);
    value = result;
  }

  Future<List<AppFSAttr>> readDir(
    String fullPath, {
    List<String> skip = const ['.'],
    bool followLinks = false,
  });

  Future<Uint8List> readFile(String fullPath);

  Future<void> rename(String oldPath, String newPath);

  Future<AppFSAttr> stat(String fullPath, {bool followLink = false});

  Future<void> writeFile(String fullPath, Uint8List data);

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _value.clear();
    path.dispose();
  }
}

class AppLocalFSSession extends AppFSSession {
  AppLocalFSSession({required super.name, required String initialPath}) {
    path.text = initialPath;
    listDir();
  }

  @override
  Future<void> create(
    String fullPath,
    AppFSAttrType type, {
    String? extra,
    bool recursive = false,
    bool exclusive = false,
  }) async {
    switch (type) {
      case AppFSAttrType.dir:
        final dir = Directory(fullPath);
        if (!await dir.exists()) await dir.create(recursive: recursive);
        break;
      case AppFSAttrType.link:
        final link = Link(fullPath);
        if (!await link.exists() && extra != null) {
          await link.create(extra, recursive: recursive);
        }
        break;
      case AppFSAttrType.file:
        final file = File(fullPath);
        if (!await file.exists()) {
          await file.create(recursive: recursive, exclusive: exclusive);
        }
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  @override
  Future<void> delete(String fullPath, {bool recursive = false}) async {
    final type = AppFSAttrType.fromFSEntityType(
      await FileSystemEntity.type(fullPath, followLinks: false),
    );
    switch (type) {
      case AppFSAttrType.dir:
        final dir = Directory(fullPath);
        await dir.delete(recursive: recursive);
        break;
      case AppFSAttrType.link:
        final link = Link(fullPath);
        await link.delete(recursive: recursive);
        break;
      case AppFSAttrType.file:
        final file = File(fullPath);
        await file.delete(recursive: recursive);
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  @override
  Future<bool> exists(String fullPath) async {
    final type = AppFSAttrType.fromFSEntityType(
      await FileSystemEntity.type(fullPath, followLinks: false),
    );
    return switch (type) {
      AppFSAttrType.dir => Directory(fullPath).exists(),
      AppFSAttrType.link => Link(fullPath).exists(),
      AppFSAttrType.file => File(fullPath).exists(),
      AppFSAttrType.unknown => Future.value(true),
      AppFSAttrType.notFound => Future.value(false),
    };
  }

  @override
  Future<String?> linkTarget(String fullPath) async {
    try {
      final link = Link(fullPath);
      if (await link.exists()) return link.resolveSymbolicLinks();
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AppFSAttr>> readDir(
    String fullPath, {
    List<String> skip = const ['.'],
    bool followLinks = false,
  }) async {
    final dir = Directory(fullPath);
    if (!await dir.exists()) return [];
    final parentDir = dir.parent.absolute;
    final parentStat = await parentDir.stat();
    final result = <AppFSAttr>[];
    if (!skip.contains('..')) {
      result.add(AppFSAttr(
        fileName: '..',
        fullPath: parentDir.path,
        type: AppFSAttrType.dir,
        accessTime: parentStat.accessed,
        modifyTime: parentStat.modified,
        size: parentStat.size,
        mode: parentStat.mode,
      ));
    }
    await for (final entity in dir.list(followLinks: followLinks)) {
      final entityName = p.basename(entity.path);
      if (!skip.contains(entityName)) {
        final path = entity.absolute.path;
        final stat = await entity.stat();
        final isLink = await FileSystemEntity.isLink(path);
        result.add(AppFSAttr(
          fileName: entityName,
          fullPath: path,
          linkPath: isLink ? await Link(path).target() : null,
          type: isLink
              ? AppFSAttrType.link
              : AppFSAttrType.fromFSEntityType(stat.type),
          accessTime: stat.accessed,
          modifyTime: stat.modified,
          size: stat.size,
          mode: stat.mode,
        ));
      }
    }
    return result;
  }

  @override
  Future<Uint8List> readFile(String fullPath) async {
    final file = File(fullPath);
    if (!await file.exists()) return Uint8List(0);
    return file.readAsBytes();
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    final type = AppFSAttrType.fromFSEntityType(
      await FileSystemEntity.type(oldPath, followLinks: false),
    );
    switch (type) {
      case AppFSAttrType.dir:
        final dir = Directory(oldPath);
        if (!await dir.exists()) await dir.rename(newPath);
        break;
      case AppFSAttrType.link:
        final link = Link(oldPath);
        if (!await link.exists()) await link.rename(newPath);
        break;
      case AppFSAttrType.file:
        final file = File(oldPath);
        if (!await file.exists()) await file.rename(newPath);
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  @override
  Future<AppFSAttr> stat(String fullPath, {bool followLink = false}) async {
    final type = AppFSAttrType.fromFSEntityType(
      await FileSystemEntity.type(fullPath, followLinks: followLink),
    );
    late final FileStat stat;
    late final AppFSAttr result;
    switch (type) {
      case AppFSAttrType.dir:
        stat = await Directory(fullPath).stat();
        result = AppFSAttr(
          fileName: p.basename(fullPath),
          fullPath: fullPath,
          type: type,
          accessTime: stat.accessed,
          modifyTime: stat.modified,
          size: stat.size,
          mode: stat.mode,
        );
        break;
      case AppFSAttrType.link:
        stat = await Directory(fullPath).stat();
        result = AppFSAttr(
          fileName: p.basename(fullPath),
          fullPath: fullPath,
          linkPath: await linkTarget(fullPath),
          type: type,
          accessTime: stat.accessed,
          modifyTime: stat.modified,
          size: stat.size,
          mode: stat.mode,
        );
        break;
      case AppFSAttrType.file:
        stat = await Directory(fullPath).stat();
        result = AppFSAttr(
          fileName: p.basename(fullPath),
          fullPath: fullPath,
          type: type,
          accessTime: stat.accessed,
          modifyTime: stat.modified,
          size: stat.size,
          mode: stat.mode,
        );
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
    return result;
  }

  @override
  Future<void> writeFile(String fullPath, Uint8List data) async {
    final file = File(fullPath);
    await file.writeAsBytes(data);
  }
}

class AppSftpSession extends AppFSSession {
  AppSftpSession({
    required super.name,
    required this.client,
    required String initialPath,
  }) {
    path.text = initialPath;
    listDir();
  }

  final SftpClient client;

  @override
  String absolute(String base, [String? extra]) {
    final separator = '/';
    if (extra != null) {
      return p.normalize(
        base + (base.endsWith(separator) ? '' : separator) + extra,
      );
    } else {
      return p.normalize(base);
    }
  }

  @override
  Future<void> create(
    String fullPath,
    AppFSAttrType type, {
    String? extra,
    bool recursive = false,
    bool exclusive = false,
  }) async {
    final dirName = fullPath.substring(0, fullPath.lastIndexOf('/'));
    if (recursive && !await _exists(dirName)) {
      await create(dirName, AppFSAttrType.dir, recursive: recursive);
    }
    switch (type) {
      case AppFSAttrType.dir:
        await client.mkdir(fullPath);
        break;
      case AppFSAttrType.link:
        if (extra != null) await client.link(fullPath, extra);
        break;
      case AppFSAttrType.file:
        late final SftpFileOpenMode mode;
        if (exclusive) {
          mode = SftpFileOpenMode.create | SftpFileOpenMode.exclusive;
        } else {
          mode = SftpFileOpenMode.create;
        }
        final file = await client.open(
          fullPath,
          mode: mode,
        );
        file.close();
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  @override
  Future<void> delete(String fullPath, {bool recursive = false}) async {
    if (!await exists(fullPath)) return;
    final type = ExAppFSEntityType.fromSftpFileType(
      (await client.stat(fullPath, followLink: false)).type,
    );
    switch (type) {
      case AppFSAttrType.dir:
        if (recursive) {
          final dir = await readDir(fullPath, skip: ['.', '..']);
          if (dir.isEmpty) {
            await client.rmdir(fullPath);
          } else {
            for (final i in dir) {
              await delete(i.fullPath, recursive: recursive);
            }
            await client.rmdir(fullPath);
          }
        } else {
          await client.rmdir(fullPath);
        }
        break;
      case AppFSAttrType.link:
      case AppFSAttrType.file:
        await client.remove(fullPath);
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  @override
  Future<bool> exists(String fullPath) {
    return _exists(fullPath, followLink: false);
  }

  @override
  Future<String?> linkTarget(String fullPath) async {
    try {
      if (!await _exists(fullPath)) return null;
      final result = await client.readlink(fullPath);
      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AppFSAttr>> readDir(
    String fullPath, {
    List<String> skip = const ['.'],
    bool followLinks = false,
  }) async {
    final result = <AppFSAttr>[];
    if (!await exists(fullPath)) return result;
    final dirResult = await client.listdir(fullPath);
    for (final i in dirResult) {
      if (!skip.contains(i.filename)) {
        final attr = i.attr;
        final type = ExAppFSEntityType.fromSftpFileType(attr.type);
        result.add(AppFSAttr(
          fileName: i.filename,
          fullPath: '$fullPath/${i.filename}',
          linkPath: type == AppFSAttrType.link
              ? await linkTarget('$fullPath/${i.filename}')
              : null,
          type: type,
          accessTime: attr.accessTime != null
              ? DateTime.fromMillisecondsSinceEpoch(attr.accessTime! * 1000)
              : null,
          modifyTime: attr.modifyTime != null
              ? DateTime.fromMillisecondsSinceEpoch(attr.modifyTime! * 1000)
              : null,
          size: attr.size,
          mode: attr.mode?.value,
        ));
      }
    }
    return result;
  }

  @override
  Future<Uint8List> readFile(String fullPath) async {
    if (!await exists(fullPath)) return Uint8List(0);
    final file = await client.open(fullPath);
    final data = await file.readBytes();
    await file.close();
    return data;
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    if (!await exists(oldPath)) return;
    await client.rename(oldPath, newPath);
  }

  @override
  Future<AppFSAttr> stat(String fullPath, {bool followLink = false}) async {
    if (!await exists(fullPath)) {
      return AppFSAttr(
        fileName: p.basename(fullPath),
        fullPath: fullPath,
        type: AppFSAttrType.notFound,
      );
    }
    final stat = await client.stat(fullPath, followLink: followLink);
    final type = ExAppFSEntityType.fromSftpFileType(stat.type);
    return AppFSAttr(
      fileName: p.basename(fullPath),
      fullPath: fullPath,
      linkPath: type == AppFSAttrType.link ? await linkTarget(fullPath) : null,
      type: type,
      accessTime: stat.accessTime != null
          ? DateTime.fromMillisecondsSinceEpoch(stat.accessTime! * 1000)
          : null,
      modifyTime: stat.modifyTime != null
          ? DateTime.fromMillisecondsSinceEpoch(stat.modifyTime! * 1000)
          : null,
      size: stat.size,
      mode: stat.mode?.value,
    );
  }

  @override
  Future<void> writeFile(String fullPath, Uint8List data) async {
    final file = await client.open(
      fullPath,
      mode: SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write,
    );
    await file.writeBytes(data);
    await file.close();
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
  }

  Future<bool> _exists(String fullPath, {bool followLink = true}) async {
    try {
      await client.stat(fullPath, followLink: followLink);
      return true;
    } catch (e) {
      if (e is SftpStatusError) {
        if (e.code == 2) return false;
      } else if (e is SftpError) {
        return false;
      }
      return true;
    }
  }
}

class _PanelIterator<E> implements Iterator<E> {
  _PanelIterator.fromIterable(this.iterable);

  final Iterable<E> iterable;

  int? _index;
  late E _current;

  @override
  E get current {
    if (_index == null) {
      throw 'If this value is used for the first time, moveNext must be called first.';
    }
    return _current;
  }

  @override
  bool moveNext() {
    if (hasNext()) {
      if (_index == null) {
        _index = 0;
      } else {
        _index = _index! + 1;
      }
      _current = iterable.elementAt(_index!);
      return true;
    } else {
      return false;
    }
  }

  bool hasNext() {
    if (_index == null) return true;
    if ((_index! + 1) < iterable.length) return true;
    return false;
  }
}

class PanelData {
  PanelData({
    required this.index,
    required this.sessions,
  });

  int index;
  final List<AppFSSession> sessions;

  AppFSSession? get currentSession => sessions.elementAtOrNull(index);

  void add(AppFSSession newSession) {
    sessions.add(newSession);
    index = sessions.length - 1;
  }

  AppFSSession removeAt(int removeIndex) {
    assert(sessions.isNotEmpty && removeIndex < sessions.length);
    final result = sessions.removeAt(removeIndex);
    if (removeIndex <= index) {
      final newIndex = index - 1;
      index = newIndex > 0 ? newIndex : 0;
    }
    return result;
  }

  void insert(int insertIndex, AppFSSession newSession) {
    assert(sessions.isNotEmpty && insertIndex <= sessions.length);
    sessions.insert(insertIndex, newSession);
    if (insertIndex < index) {
      index = index + 1;
    }
  }

  void dispose() {
    for (final i in sessions) {
      i.dispose();
    }
  }
}

class PanelController extends ChangeNotifier
    implements ValueListenable<Map<int, PanelData>> {
  PanelController();

  final _value = <int, PanelData>{};
  @override
  Map<int, PanelData> get value => Map.unmodifiable(_value);

  int get length => _value.length;

  PanelData? operator [](int id) {
    return _value[id];
  }

  void operator []=(int id, PanelData data) {
    _value[id] = data;
    notifyListeners();
  }

  void addAll(Map<int, PanelData> other) {
    _value.addAll(other);
    notifyListeners();
  }

  void remove(int id) {
    if (_value.remove(id) != null) notifyListeners();
  }

  int indexAt(int id) {
    assert(_value[id] != null);
    return _value[id]!.index;
  }

  void changeIndexAt(int id, int newIndex) {
    assert(_value[id] != null);
    _value[id]!.index = newIndex;
    notifyListeners();
  }

  void addSessionAt(int id, AppFSSession newSession) {
    assert(_value[id] != null);
    _value[id]!.add(newSession);
    notifyListeners();
  }

  AppFSSession removeSessionAt(int id, int index) {
    assert(_value[id] != null);
    final result = _value[id]!.removeAt(index);
    notifyListeners();
    return result;
  }

  void insertSessionAt(int id, int index, AppFSSession newSession) {
    assert(_value[id] != null);
    _value[id]!.insert(index, newSession);
    notifyListeners();
  }

  List<int> panelIdList(int exclude) {
    final result = <int>[];
    for (final i in _value.entries) {
      if (i.key != exclude && i.value.currentSession != null) {
        result.add(i.key);
      }
    }
    return result;
  }

  @override
  void dispose() {
    super.dispose();
    for (final i in _value.values) {
      i.dispose();
    }
    _value.clear();
  }
}

class AppPanel extends StatelessWidget {
  const AppPanel._({
    super.key,
    this.session,
    this.controller,
    this.headerBuilder,
    required this.placeholder,
    this.tooltip,
    required this.taskHandler,
    required this.fileHandlerBuilder,
    required this.isSingle,
  });

  const AppPanel.single({
    Key? key,
    required AppFSSession? session,
    Widget placeholder = const SizedBox.shrink(),
    String? tooltip,
    required void Function(List<Future<void> Function()>) taskHandler,
    required Widget Function(String, Uint8List?) fileHandlerBuilder,
  }) : this._(
          key: key,
          session: session,
          placeholder: placeholder,
          tooltip: tooltip,
          taskHandler: taskHandler,
          fileHandlerBuilder: fileHandlerBuilder,
          isSingle: true,
        );

  const AppPanel.multiple({
    Key? key,
    required PanelController controller,
    Widget Function(int, int, List<AppFSSession>)? headerBuilder,
    Widget placeholder = const SizedBox.shrink(),
    String? tooltip,
    required void Function(List<Future<void> Function()>) taskHandler,
    required Widget Function(String, Uint8List?) fileHandlerBuilder,
  }) : this._(
          key: key,
          controller: controller,
          headerBuilder: headerBuilder,
          placeholder: placeholder,
          tooltip: tooltip,
          taskHandler: taskHandler,
          fileHandlerBuilder: fileHandlerBuilder,
          isSingle: false,
        );

  final AppFSSession? session;
  final PanelController? controller;
  final Widget Function(int, int, List<AppFSSession>)? headerBuilder;
  final Widget placeholder;
  final String? tooltip;
  final void Function(List<Future<void> Function()>) taskHandler;
  final Widget Function(String, Uint8List?) fileHandlerBuilder;
  final bool isSingle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isSingle) {
      return Material(
        child: AnimatedSwitcher(
          duration: Durations.short4,
          child: session != null ? _buildPanel(session!) : placeholder,
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder(
            valueListenable: controller!,
            builder: (context, value, _) {
              return _buildPanelList(
                constraints.maxWidth,
                value,
                theme.colorScheme.onSurface,
              );
            },
          );
        },
      );
    }
  }

  Widget _buildPanelList(
    double panelWidth,
    Map<int, PanelData> sessions,
    Color dividerColor,
  ) {
    final iterator = _PanelIterator.fromIterable(sessions.entries);
    final content = <Widget>[];
    while (iterator.moveNext()) {
      final i = iterator.current;
      final currentSession = i.value.currentSession;
      final dividerSpace = (sessions.length - 1) / sessions.length;
      content.add(
        SizedBox(
          width: panelWidth / 2 - dividerSpace,
          child: Column(
            children: [
              if (headerBuilder != null)
                headerBuilder!.call(
                  i.key,
                  i.value.index,
                  i.value.sessions,
                ),
              Container(
                height: 1.0,
                color: dividerColor,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Durations.short4,
                  child: currentSession != null
                      ? _buildPanel(
                          currentSession,
                          controller!.panelIdList(i.key),
                        )
                      : placeholder,
                ),
              ),
            ],
          ),
        ),
      );
      if (iterator.hasNext()) {
        content.add(Container(
          width: 1.0,
          color: dividerColor,
        ));
      }
    }
    return Material(
      child: Row(
        children: content,
      ),
    );
  }

  Widget _buildPanel(
    AppFSSession session, [
    List<int> idList = const [],
  ]) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextField(
            controller: session.path,
            onEditingComplete: () => session.listDir(),
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
                  onPressed: () => session.listDir(),
                  icon: const Icon(Icons.refresh),
                  tooltip: tooltip,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: session,
            builder: (context, dir, _) {
              return ListView.builder(
                itemCount: dir.length,
                itemBuilder: (context, index) {
                  final attr = dir[index];
                  return _buildItem(
                    attr,
                    () => _onTap(context, attr, session),
                    () => _onSecondaryTap(context, attr, idList, session),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    AppFSAttr attr,
    VoidCallback onTap,
    VoidCallback onSecondaryTap,
  ) {
    final icon = () {
      return switch (attr.type) {
        AppFSAttrType.dir => Icon(Icons.folder),
        AppFSAttrType.link => Icon(Icons.link),
        AppFSAttrType.file => Icon(Icons.description),
        _ => Icon(Icons.question_mark),
      };
    }();

    return InkWell(
      onTap: onTap,
      onLongPress: onSecondaryTap,
      onSecondaryTap: onSecondaryTap,
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
                    child: Text(
                      attr.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
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

  void _onTap(
      BuildContext context, AppFSAttr attr, AppFSSession session) async {
    switch (attr.type) {
      case AppFSAttrType.dir:
        session.path.text = attr.fullPath;
        session.listDir();
        break;
      case AppFSAttrType.file:
        _showFileHandler(context, attr, session);
        break;
      case AppFSAttrType.link:
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
  }

  // TODO
  void _onSecondaryTap(
    BuildContext context,
    AppFSAttr attr,
    List<int> idList,
    AppFSSession from,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return _ContextDialog(idList: idList, attr: attr);
      },
    );
    final uri = Uri.tryParse(result ?? '');
    switch (uri?.path) {
      case 'copy':
        final id = uri!.queryParameters['id'];
        if (id != null && context.mounted) {
          _onCopy(
            context,
            attr,
            from,
            controller![int.parse(id)]!.currentSession!,
          );
        }
        break;
      case 'cut':
        break;
      case 'delete':
        break;
      case _:
        break;
    }
  }

  void _onCopy(
    BuildContext context,
    AppFSAttr attr,
    AppFSSession from,
    AppFSSession to,
  ) async {
    late final String copyName;
    final toDirNames = to.value.map((e) => e.fileName).toSet();
    if (toDirNames.contains(attr.fileName)) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return _InputDialog(
            defaultValue: _genNewName(toDirNames, attr.fileName),
            title: Text('Copy'),
          );
        },
      );
      if (result != null && result.isNotEmpty) {
        copyName = result;
      } else {
        return;
      }
    } else {
      copyName = attr.fileName;
    }
    final toPath = to.absolute(to.path.text, copyName);
    final taskList = await _genTask(attr, toPath, from, to);
    taskHandler.call(taskList);
  }

  void _showFileHandler(
    BuildContext context,
    AppFSAttr attr,
    AppFSSession session,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_back),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: write file
                  },
                  icon: Icon(Icons.save),
                ),
              ],
            ),
            body: FutureBuilder(
              future: session.readFile(attr.fullPath),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    }
                    return fileHandlerBuilder.call(
                      attr.fileName,
                      snapshot.data,
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }

  String _genNewName(Iterable<String> nameList, String oldName) {
    int i = 1;
    final nonExtension = p.basenameWithoutExtension(oldName);
    final extension = oldName.replaceFirst(nonExtension, '');
    while (nameList.contains('$nonExtension($i)$extension')) {
      i++;
    }
    return '$nonExtension($i)$extension';
  }

  Future<List<Future<void> Function()>> _genTask(
    AppFSAttr attr,
    String toPath,
    AppFSSession from,
    AppFSSession to,
  ) async {
    final result = <Future Function()>[];
    switch (attr.type) {
      case AppFSAttrType.dir:
        result.add(() async {
          await to.create(toPath, attr.type);
        });
        final dir = await from.readDir(attr.fullPath, skip: ['.', '..']);
        for (final i in dir) {
          result.addAll(await _genTask(
            i,
            to.absolute(toPath, i.fileName),
            from,
            to,
          ));
        }
        break;
      case AppFSAttrType.link:
        result.add(() async {
          await to.create(toPath, attr.type, extra: attr.linkPath);
        });
        break;
      case AppFSAttrType.file:
        result.add(() async {
          await to.create(toPath, attr.type);
          final data = await from.readFile(attr.fullPath);
          await to.writeFile(toPath, data);
        });
        break;
      case AppFSAttrType.unknown:
      case AppFSAttrType.notFound:
        break;
    }
    return result;
  }
}

class _ContextDialog extends StatefulWidget {
  const _ContextDialog({required this.idList, required this.attr});

  /// 当前可用的id，不包括panel自身
  final List<int> idList;
  final AppFSAttr attr;

  @override
  State<_ContextDialog> createState() => _ContextDialogState();
}

class _ContextDialogState extends State<_ContextDialog>
    implements ValueListenable<List<Page>> {
  final _listeners = <VoidCallback>[];
  final _value = <Page>[];

  late final NavigatorState _rootNavigator;

  @override
  List<Page> get value => List.unmodifiable(_value);

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void initState() {
    super.initState();
    _rootNavigator = Navigator.of(context, rootNavigator: true);
    _onShowMainPage();
  }

  @override
  void dispose() {
    super.dispose();
    _listeners.clear();
    _value.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: this,
      builder: (context, value, _) {
        return Dialog(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth / 2,
                height: constraints.maxHeight / 2,
                child: _buildDialogContent(),
              );
            },
          ),
        );
      },
    );
  }

  void _notifyListeners() {
    for (final f in _listeners) {
      f();
    }
  }

  Widget _buildDialogContent() {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: value.length > 1 ? _onPop : null,
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(widget.attr.fileName),
        ),
        Expanded(
          child: Navigator(
            pages: value,
            onDidRemovePage: _onDidRemovePage,
          ),
        ),
      ],
    );
  }

  void _onPop() {
    _value.removeLast();
    _notifyListeners();
  }

  void _onDidRemovePage(Page page) {
    if (page.name == '/main') {
      _value.add(page);
      _notifyListeners();
    }
  }

  void _onPopDialog(String action, [Map<String, String>? queryParams]) {
    final uri = Uri(path: action, queryParameters: queryParams);
    _rootNavigator.pop(uri.toString());
  }

  void _onShowMainPage() {
    final extra = <Widget>[];
    if (widget.idList.isNotEmpty) {
      for (final i in widget.idList) {
        extra.addAll([
          ListTile(
            title: Text('Copy to $i'),
            onTap: () => _onPopDialog('copy', {'id': '$i'}),
          ),
          ListTile(
            title: Text('Cut to $i'),
            onTap: () => _onPopDialog('cut', {'id': '$i'}),
          ),
        ]);
      }
    }

    _value.add(_FadeAnimationPage(
      name: '/main',
      child: ListView(
        children: [
          ...extra,
          ListTile(
            title: Text('Delete'),
            onTap: () => _onPopDialog('delete'),
          ),
          ListTile(
            title: Text('Info'),
            onTap: _onShowInfoPage,
          ),
        ],
      ),
    ));
    _notifyListeners();
  }

  void _onShowInfoPage() {
    _value.add(_FadeAnimationPage(
      name: '/info',
      child: ListView(
        children: [
          ListTile(
            title: Text(widget.attr.modifyTime.toString()),
          ),
          ListTile(
            title: Text(widget.attr.accessTime.toString()),
          ),
          ListTile(
            title: Text('${widget.attr.size}'),
          ),
          ListTile(
            title: Text('${widget.attr.mode}'),
          ),
        ],
      ),
    ));
    _notifyListeners();
  }
}

class _FadeAnimationPage<T> extends Page<T> {
  const _FadeAnimationPage({
    super.key,
    super.name,
    required this.child,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    required this.defaultValue,
    required this.title,
  });

  final String defaultValue;
  final Widget title;

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  late final NavigatorState _rootNavigator;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _rootNavigator = Navigator.of(context, rootNavigator: true);
    _controller = TextEditingController(text: widget.defaultValue);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth / 2,
          child: AlertDialog(
            title: widget.title,
            content: TextField(
              controller: _controller,
            ),
            actions: [
              TextButton(
                onPressed: () => _rootNavigator.pop(),
                child: Text('Cancle'),
              ),
              FilledButton.tonal(
                onPressed: () => _rootNavigator.pop(_controller.text),
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
