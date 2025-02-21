import 'dart:io';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/utils/manage.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:toastification/toastification.dart';

class FileManagerPanel extends StatelessWidget {
  const FileManagerPanel({super.key, required this.session});

  final DirSession session;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: session.pathController,
                  onEditingComplete: session.listDir,
                ),
              ),
              IconButton(
                onPressed: () => session.listDir(force: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: session.lastError,
            builder: (context, error, child) {
              return AnimatedSwitcher(
                duration: kAnimationDuration,
                child: error != null ? Center(child: Text('$error')) : child,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
              );
            },
            child: ValueListenableBuilder(
              valueListenable: session.lastDirResult,
              builder: (context, dir, _) {
                return ListView.builder(
                  itemCount: dir.length,
                  itemBuilder: (context, index) {
                    return _buildDirItem(context, dir[index]);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirItem(BuildContext context, DirItem item) {
    return ListTile(
      leading: () {
        switch (item.type) {
          case DirItemType.dir:
            return Icon(Icons.folder);
          case DirItemType.link:
            return Icon(Icons.link);
          case DirItemType.file:
            return Icon(Icons.description);
          case DirItemType.unknown:
            return Icon(Icons.question_mark);
        }
      }(),
      title: Text(
        item.name,
        overflow: TextOverflow.clip,
      ),
      onTap: () {
        switch (item.type) {
          case DirItemType.dir:
            session.openDir(item.name);
            break;
          case DirItemType.link:
            break;
          case DirItemType.file:
            _showModifier(context, item.name);
            break;
          case DirItemType.unknown:
            break;
        }
      },
    );
  }

  Future<T?> _showModifier<T>(BuildContext context, String fileName) {
    return showDialog<T?>(
      context: context,
      builder: (context) {
        return FileModifierDialog(
          fileLoader: session.openFile(fileName),
          save: session.editFile,
        );
      },
    );
  }
}

class FileModifierDialog extends StatefulWidget {
  const FileModifierDialog({
    super.key,
    required this.fileLoader,
    required this.save,
  });

  final Future<File> fileLoader;
  final Future<void> Function(File) save;

  @override
  State<FileModifierDialog> createState() => _FileModifierDialogState();
}

class _FileModifierDialogState extends State<FileModifierDialog> {
  final _lastError = ValueNotifier<Object?>(null);
  final _controller = CodeLineEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: FutureBuilder(
        future: widget.fileLoader,
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
              if (snapshot.hasData) {
                snapshot.data!.readAsString().then(
                      (text) => _controller.text = text,
                      onError: (error) => _lastError.value = error,
                    );

                return Scaffold(
                  appBar: AppBar(
                    title: Text('Modifier'),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          onPressed: () {
                            _waitting(
                                context,
                                Future.value([
                                  snapshot.data!.writeAsString(
                                    _controller.text + Platform.lineTerminator,
                                  ),
                                  widget.save(snapshot.data!),
                                ]));
                          },
                          icon: Icon(Icons.save),
                        ),
                      ),
                    ],
                  ),
                  body: ValueListenableBuilder(
                    valueListenable: _lastError,
                    builder: (context, error, _) {
                      return AnimatedSwitcher(
                        duration: kAnimationDuration,
                        child: error != null
                            ? Center(child: Text('$error'))
                            : CodeEditor(
                                controller: _controller,
                                wordWrap: false,
                                indicatorBuilder: (context, editingController,
                                    chunkController, notifier) {
                                  return Row(
                                    children: [
                                      DefaultCodeLineNumber(
                                        controller: editingController,
                                        notifier: notifier,
                                      ),
                                      DefaultCodeChunkIndicator(
                                        width: 20,
                                        controller: chunkController,
                                        notifier: notifier,
                                      )
                                    ],
                                  );
                                },
                                toolbarController:
                                    const ContextMenuControllerImpl(),
                                sperator: Container(
                                  width: 1,
                                  color: Colors.blue,
                                ),
                              ),
                      );
                    },
                  ),
                );
              } else {
                return Center(child: Text('Empty content.'));
              }
          }
        },
      ),
    );
  }

  void _waitting<T>(BuildContext context, Future<T> future) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Navigator.of(context).pop(true);
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
    if (result != null) {
      toastification.show(
        type: ToastificationType.info,
        autoCloseDuration: kBackDuration,
        animationDuration: kAnimationDuration,
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        title: Text('Success'),
        alignment: Alignment.bottomCenter,
        style: ToastificationStyle.simple,
      );
    }
  }
}

// from re-editor example
class ContextMenuItemWidget extends PopupMenuItem<void>
    implements PreferredSizeWidget {
  ContextMenuItemWidget({
    super.key,
    required String text,
    required VoidCallback super.onTap,
  }) : super(child: Text(text));

  @override
  Size get preferredSize => const Size(150, 25);
}

// from re-editor example
class ContextMenuControllerImpl implements SelectionToolbarController {
  const ContextMenuControllerImpl();

  @override
  void hide(BuildContext context) {}

  @override
  void show({
    required BuildContext context,
    required CodeLineEditingController controller,
    required TextSelectionToolbarAnchors anchors,
    Rect? renderRect,
    required LayerLink layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    showMenu(
        context: context,
        position: RelativeRect.fromSize(
            anchors.primaryAnchor & const Size(150, double.infinity),
            MediaQuery.of(context).size),
        items: [
          ContextMenuItemWidget(
            text: 'Cut',
            onTap: () {
              controller.cut();
            },
          ),
          ContextMenuItemWidget(
            text: 'Copy',
            onTap: () {
              controller.copy();
            },
          ),
          ContextMenuItemWidget(
            text: 'Paste',
            onTap: () {
              controller.paste();
            },
          ),
        ]);
  }
}
