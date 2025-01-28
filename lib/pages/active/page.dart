import 'package:a_terminal/pages/active/logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

class ActivePage extends StatelessWidget {
  const ActivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActiveLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<ActiveLogic>();

        return ValueListenableBuilder(
          valueListenable: logic.scaffoldLogic.tabIndex,
          builder: (context, index, __) {
            return FutureBuilder(
              future:
                  Future.value(logic.scaffoldLogic.activeTerms[index].create()),
              builder: (context, snapshot) {
                return ValueListenableBuilder(
                  valueListenable: logic.fontSizeL,
                  builder: (context, fontSize, _) {
                    return TerminalView(
                      logic.scaffoldLogic.activeTerms[index].terminal,
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
