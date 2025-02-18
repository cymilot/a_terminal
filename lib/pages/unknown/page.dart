import 'package:a_terminal/pages/unknown/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => UnknownLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<UnknownLogic>();
        return Center(
          child: TextButton(
            onPressed: logic.onBack,
            child: Text('back'.tr(context)),
          ),
        );
      },
    );
  }
}
