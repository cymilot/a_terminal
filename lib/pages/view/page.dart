import 'package:a_terminal/pages/view/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/pages/view/panel.dart';
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
        final isWideScreen = context.isWideScreen;
        return ValueListenableBuilder(
          valueListenable: logic.scaffoldLogic.tabIndex,
          builder: (context, index, _) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          _buildTerminalView(logic, index),
                          isWideScreen
                              ? _buildRightPanel(logic, index)
                              : const SizedBox.shrink(),
                        ],
                      ),
                      !isWideScreen
                          ? Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              child: _buildRightPanel(logic, index),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                // Footer Button
                Container(
                  height: 50.0,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow
                      .withValues(alpha: 0.38),
                  child: _buildButtonGroup(logic),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTerminalView(ViewLogic logic, int index) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: logic.fontSize,
        builder: (context, fontSize, _) {
          return TerminalView(
            logic.scaffoldLogic.activated[index]
                .createTerminal(logic.settings.value),
            textStyle: TerminalStyle(fontSize: fontSize),
            onKeyEvent: logic.onTerminalViewKeyEvent,
          );
        },
      ),
    );
  }

  Widget _buildRightPanel(ViewLogic logic, int index) {
    return SftpPanel(
      client: logic.scaffoldLogic.activated[index],
      extendedNotifier: logic.opened,
      extendedDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildButtonGroup(ViewLogic logic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: logic.onOpenSidePanel,
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }
}
