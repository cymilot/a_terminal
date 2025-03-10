import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/pages/view/logic.dart';
import 'package:a_terminal/utils/edit.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

class ViewPage extends StatelessWidget {
  const ViewPage({super.key, this.queryParams});

  final Map<String, String>? queryParams;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ViewLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<ViewLogic>();

        return ValueListenableBuilder(
          valueListenable: logic.scaffoldLogic.tabIndex,
          builder: (context, index, _) {
            return Column(
              children: [
                Expanded(
                  child: _buildMainContent(logic, index),
                ),
                Container(
                  height: 50.0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: _buildButtonGroup(context, logic),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent(ViewLogic logic, int index) {
    return ValueListenableBuilder(
      valueListenable: logic.appLogic.isWideScreen,
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              children: [
                _buildTerminalView(logic, index),
                AnimatedSwitcher(
                  duration: kAnimationDuration,
                  layoutBuilder: (c, p) =>
                      switcherLayout(Alignment.centerRight, c, p),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    );
                  },
                  child: value
                      ? _buildPanel(logic, index)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            if (!value) _buildPanel(logic, index),
          ],
        );
      },
    );
  }

  Widget _buildTerminalView(ViewLogic logic, int index) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: logic.fontSize,
        builder: (context, fontSize, _) {
          final result = logic.activated[index].createTerminal(logic.settings);

          return TerminalView(
            result.$1,
            controller: result.$2,
            textStyle: TerminalStyle(fontSize: fontSize),
            onKeyEvent: logic.onTerminalViewKeyEvent,
          );
        },
      ),
    );
  }

  Widget _buildPanel(ViewLogic logic, int index) {
    return ValueListenableBuilder(
      valueListenable: logic.opened,
      builder: (context, extended, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          layoutBuilder: (c, p) => switcherLayout(Alignment.centerRight, c, p),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            );
          },
          child: extended
              ? _buildPanelContent(
                  extended,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.66),
                  logic.activated[index],
                  logic.settings,
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildPanelContent(
    bool extended,
    Color backgroundColor,
    ActivatedClient client,
    Settings settings,
  ) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      width: extended ? 288.0 : 0.0,
      color: backgroundColor,
      child: FutureBuilder(
        future: Future.value(client.createFileManager(settings)),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                return AppFSManagerPanel(
                  session: snapshot.data!,
                  refreshTooltip: 'refresh'.tr(context),
                  onOpenFile: (context, entity, data) => onOpenFile(
                    context,
                    entity,
                    data,
                    snapshot.data!.saveFile,
                  ),
                  onError: errorToast,
                );
              } else {
                return Center(child: Text('emptyData'.tr(context)));
              }
          }
        },
      ),
    );
  }

  Widget _buildButtonGroup(BuildContext context, ViewLogic logic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: logic.onTapIncreaseFontSize,
            icon: Icon(Icons.text_increase),
          ),
          IconButton(
            onPressed: logic.onTapDecreaseFontSize,
            icon: Icon(Icons.text_decrease),
          ),
          Spacer(),
          IconButton(
            onPressed: logic.onOpenSidePanel,
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }
}
