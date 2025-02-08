import 'package:a_terminal/pages/terminal/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TerminalLogic(context: context),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<TerminalLogic>();
        return logic.scaffoldLogic.activated.isNotEmpty
            ? ListView(
                children: logic.genViewItems(),
              )
            : Center(child: Text('noTerm'.tr(context)));
      },
    );
  }
}
