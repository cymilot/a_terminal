import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalLogic {
  TerminalLogic(this.context);

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;
  ValueNotifier<int> get tabIndex => scaffoldLogic.tabIndex;
  NavigatorState? get navigator => scaffoldLogic.navigator;

  Widget genViewItems(BuildContext context, int index) {
    final value = activated[index];
    return Card(
      child: ListTile(
        title: Text(value.clientData.clientName),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final client = activated.removeAt(index);
            client.closeAll();
            final i = index - 1;
            tabIndex.value = i >= 0 ? i : 0;
          },
        ),
        onTap: () {
          tabIndex.value = index;
          navigator?.pushUri('/view');
        },
      ),
    );
  }

  void dispose() {}
}
