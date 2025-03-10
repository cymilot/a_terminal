import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:a_terminal/consts.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';

void onOpenFile(
  BuildContext context,
  AppFSEntity entity,
  Object? data,
  Future<void> Function(String, Uint8List) onSubmit,
) =>
    showDialog(
      context: context,
      builder: (context) {
        return AppEditor(
          fileName: entity.name,
          content: data as String,
          onSubmit: onSubmit,
          onDone: () => doneToast('success'.tr(context)),
          onError: errorToast,
        );
      },
    );

class AppEditor extends StatefulWidget {
  const AppEditor({
    super.key,
    required this.fileName,
    required this.content,
    required this.onSubmit,
    this.onDone,
    this.onError,
  });

  final String fileName;
  final String content;
  final Future<void> Function(String, Uint8List) onSubmit;
  final void Function()? onDone;
  final void Function(dynamic)? onError;

  @override
  State<AppEditor> createState() => _AppEditorState();
}

class _AppEditorState extends State<AppEditor> {
  final _controller = CodeLineEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'back'.tr(context),
            onPressed: () => navigator.pop(),
            icon: Icon(Icons.arrow_back),
          ),
          leadingWidth: 72.0,
          backgroundColor: theme.colorScheme.primaryContainer,
          title: Text(widget.fileName),
          titleSpacing: 0.0,
          actions: [
            IconButton(
              tooltip: 'save'.tr(context),
              onPressed: () => _waitting(context),
              icon: Icon(Icons.save),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: CodeEditor(
          controller: _controller,
          style: CodeEditorStyle(
            fontSize: 20.0,
            fontHeight: 1.3,
          ),
          wordWrap: false,
          indicatorBuilder: _buildIndicator,
          toolbarController: const ContextMenuControllerImpl(),
          sperator: Container(
            width: 1,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    CodeLineEditingController editingController,
    CodeChunkController chunkController,
    ValueNotifier<CodeIndicatorValue?> notifier,
  ) {
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
        widget.onSubmit(
          widget.fileName,
          utf8.encode(_addSuffix(_controller.text)),
        ));

    if (result != null) {
      switch (result.type) {
        case LoadingResultType.done:
        case LoadingResultType.none:
          if (context.mounted) widget.onDone?.call();
          break;
        case LoadingResultType.error:
          widget.onError?.call(result.data);
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
          MediaQuery.of(context).size,
        ),
        items: [
          ContextMenuItemWidget(
            text: 'cut'.tr(context),
            onTap: controller.cut,
          ),
          ContextMenuItemWidget(
            text: 'copy'.tr(context),
            onTap: controller.copy,
          ),
          ContextMenuItemWidget(
            text: 'paste'.tr(context),
            onTap: controller.paste,
          ),
        ]);
  }
}
