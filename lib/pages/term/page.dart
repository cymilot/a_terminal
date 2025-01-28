import 'package:a_terminal/pages/term/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TermPage extends StatelessWidget {
  const TermPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TermLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<TermLogic>();

        return logic.scaffoldLogic.activeTerms.isNotEmpty
            ? ListView(
                children: logic.genViewItems(),
              )
            : Center(child: Text('noTerm'.tr(context)));
      },
    );
  }
}
