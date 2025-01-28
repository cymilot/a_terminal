import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/home/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<HomeLogic>();

        final theme = Theme.of(context);

        return ValueListenableBuilder(
          valueListenable: logic.termBoxL,
          builder: (context, box, _) {
            return AnimatedSwitcher(
              duration: kAnimationDuration,
              child: box.isEmpty
                  ? Center(
                      child: Text(
                        'noTerm'.tr(context),
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ValueListenableBuilder(
                      valueListenable: logic.scaffoldLogic.selectedTerms,
                      builder: (context, _, __) {
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) =>
                              logic.genViewItem(index, box),
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
