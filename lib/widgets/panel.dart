import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/utils/manage.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:toastification/toastification.dart';

enum LoadingResultType {
  done,
  error,
  none,
}

class LoadingResult {
  const LoadingResult(this.type, this.data);

  final LoadingResultType type;
  final Object? data;
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

// TODO: panel name
class FileManagerPanel extends StatelessWidget {
  const FileManagerPanel({
    super.key,
    required this.session,
    this.errorHandler = _errorHandler,
  });

  final DirSession session;
  final void Function(dynamic) errorHandler;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.66),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
      ),
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

  void _showModifier(BuildContext context, String fileName) async {
    final result = await showLoadingDialog(context, session.openFile(fileName));

    if (result != null) {
      switch (result.type) {
        case LoadingResultType.done:
        case LoadingResultType.none:
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return FileModifierDialog(
                  fileName: fileName,
                  content: result.data as String,
                  submit: session.saveFile,
                );
              },
            );
          }
          break;
        case LoadingResultType.error:
          errorHandler(result.data);
          break;
      }
    }
  }
}

class FileModifierDialog extends StatefulWidget {
  const FileModifierDialog({
    super.key,
    required this.fileName,
    required this.content,
    required this.submit,
  });

  final String fileName;
  final String content;
  final Future<void> Function(String, Uint8List) submit;

  @override
  State<FileModifierDialog> createState() => _FileModifierDialogState();
}

class _FileModifierDialogState extends State<FileModifierDialog> {
  final _controller = CodeLineEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primaryContainer,
          title: Text(widget.fileName),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => _waitting(context),
                icon: Icon(Icons.save),
              ),
            ),
          ],
        ),
        body: CodeEditor(
          controller: _controller,
          style: CodeEditorStyle(
            fontSize: 20.0,
            fontHeight: 1.3,
          ),
          wordWrap: false,
          indicatorBuilder:
              (context, editingController, chunkController, notifier) {
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
          toolbarController: const ContextMenuControllerImpl(),
          sperator: Container(
            width: 1,
            color: theme.indicatorColor,
          ),
        ),
      ),
    );
  }

  String _addSuffix(String text) {
    if (!text.endsWith(Platform.lineTerminator)) {
      return text + Platform.lineTerminator;
    }
    return text;
  }

  void _waitting(BuildContext context) async {
    final result = await showLoadingDialog(
        context,
        widget.submit(
            widget.fileName, utf8.encode(_addSuffix(_controller.text))));

    if (result != null) {
      switch (result.type) {
        case LoadingResultType.done:
        case LoadingResultType.none:
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
          break;
        case LoadingResultType.error:
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
            title: Text('${result.data}'),
            alignment: Alignment.bottomCenter,
            style: ToastificationStyle.simple,
          );
          break;
      }
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

Future<LoadingResult?> showLoadingDialog(
    BuildContext context, Future future) async {
  final result = await showDialog<LoadingResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return LoadingDialog(future: future);
    },
  );
  return result;
}

void _errorHandler(dynamic error) {
  toastification.show(
    type: ToastificationType.error,
    autoCloseDuration: kBackDuration,
    animationDuration: kAnimationDuration,
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    title: Text('$error'),
    alignment: Alignment.bottomCenter,
    style: ToastificationStyle.minimal,
  );
}
