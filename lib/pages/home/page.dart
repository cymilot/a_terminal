import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/home/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => HomeLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<HomeLogic>();
        final theme = Theme.of(context);

        return ValueListenableBuilder(
          valueListenable: logic.terminalBox.listenable(),
          builder: (context, box, _) {
            return AnimatedSwitcher(
              duration: kAnimationDuration,
              child: box.isEmpty
                  ? Center(
                      child: Text(
                        'emptyTerminal'.tr(context),
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListenableBuilder(
                      listenable: logic.selected,
                      builder: (context, _) {
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: logic.genViewItem,
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
