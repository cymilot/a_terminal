import 'package:a_terminal/pages/terminal/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => TerminalLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<TerminalLogic>();
        final theme = Theme.of(context);
        return ValueListenableBuilder(
          valueListenable: logic.scaffoldLogic.activated,
          builder: (context, value, child) {
            return value.isNotEmpty
                ? ListView.builder(
                    itemCount: value.length,
                    itemBuilder: logic.genViewItems,
                  )
                : child!;
          },
          child: Center(
            child: Text(
              'emptyTerminal'.tr(context),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}
