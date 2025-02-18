import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/sftp/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SftpPage extends StatelessWidget {
  const SftpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => SftpLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<SftpLogic>();
        final theme = Theme.of(context);
        return ValueListenableBuilder(
          valueListenable: logic.terminalBox.listenable(),
          builder: (context, _, __) {
            return AnimatedSwitcher(
              duration: kAnimationDuration,
              child: logic.sshBox.isEmpty
                  ? Center(
                      child: Text(
                        'emptyTerminal'.tr(context),
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: logic.sshBox.length,
                      itemBuilder: (context, index) => logic.genViewItem(index),
                    ),
            );
          },
        );
      },
    );
  }
}
