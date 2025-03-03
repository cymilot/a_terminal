import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/view/logic.dart';
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
                  child: _buildFooterButtonGroup(context, logic),
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
                  child: value
                      ? _buildRightPanel(logic, index)
                      : const SizedBox.shrink(),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    );
                  },
                ),
              ],
            ),
            if (!value) _buildRightPanel(logic, index),
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

  Widget _buildRightPanel(ViewLogic logic, int index) {
    return ValueListenableBuilder(
      valueListenable: logic.opened,
      builder: (context, extended, _) {
        return AnimatedSwitcher(
          duration: kAnimationDuration,
          child: extended
              ? AnimatedContainer(
                  duration: kAnimationDuration,
                  width: extended ? 288.0 : 0.0,
                  child: FutureBuilder(
                    future: Future.value(
                      logic.scaffoldLogic.activated[index].createFileManager(),
                    ),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (snapshot.hasData) {
                            return FileManagerPanel(
                              session: snapshot.data!,
                              refreshButtonTooltip: 'refresh'.tr(context),
                            );
                          } else {
                            return const Center(child: Text('Not support.'));
                          }
                      }
                    },
                  ),
                )
              : const SizedBox.shrink(),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildFooterButtonGroup(BuildContext context, ViewLogic logic) {
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
          IconButton(
            onPressed: logic.onOpenSidePanel,
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }
}
