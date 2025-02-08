import 'package:a_terminal/pages/view/logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

class ViewPage extends StatelessWidget {
  const ViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<ViewLogic>();

        return ValueListenableBuilder(
          valueListenable: logic.scaffoldLogic.tabIndex,
          builder: (context, index, __) {
            return FutureBuilder(
              future:
                  Future.value(logic.scaffoldLogic.activated[index].create()),
              builder: (context, snapshot) {
                return ValueListenableBuilder(
                  valueListenable: logic.fontSize,
                  builder: (context, fontSize, _) {
                    return TerminalView(
                      logic.scaffoldLogic.activated[index].terminal,
                      textStyle: TerminalStyle(
                        fontSize: fontSize,
                      ),
                      onKeyEvent: logic.onTerminalViewKeyEvent,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
