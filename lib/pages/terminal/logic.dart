import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TerminalLogic with ChangeNotifier {
  TerminalLogic({required this.context});

  final BuildContext context;

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  List<Widget> genViewItems() {
    return scaffoldLogic.activated.mapIndexed((index, value) {
      return Card(
        child: ListTile(
          title: Text(value.terminalData.terminalName),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              scaffoldLogic.activated.removeAt(index);
              final i = index - 1;
              scaffoldLogic.tabIndex.value = i >= 0 ? i : 0;
            },
          ),
          onTap: () {
            scaffoldLogic.tabIndex.value = index;
            scaffoldLogic.navigator?.pushUri('/view');
          },
        ),
      );
    }).toList();
  }
}
