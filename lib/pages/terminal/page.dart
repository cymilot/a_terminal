import 'package:a_terminal/hive_object/client.dart';
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
          valueListenable: logic.activated,
          builder: (context, value, child) {
            return value.isNotEmpty
                ? ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return _buildListTile(
                        logic.activated[index],
                        () => logic.onClose(index),
                        () => logic.onPush(index),
                      );
                    },
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

  Widget _buildListTile(
    ActivatedClient client,
    VoidCallback onPressed,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        title: Text(client.clientData.name),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onPressed,
        ),
        onTap: onTap,
      ),
    );
  }
}
