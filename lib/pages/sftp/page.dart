import 'package:a_terminal/pages/sftp/logic.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/material.dart';
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

        return AppPanel.multiple(
          controller: logic.scaffoldLogic.panelController,
          headerBuilder: (id, index, sessions) {
            return AppDraggableTabBar(
              items: sessions.map((e) {
                return AppDraggableTab(
                  key: e.key,
                  label: Text(e.name),
                );
              }).toList(),
              header: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => logic.onTapAdd(id),
                  icon: Icon(Icons.add),
                ),
              ),
              selectedIndex: index,
              onItemSelected: (value) => logic.onItemSelected(id, value),
              onItemRemoved: (value) => logic.onItemRemoved(id, value),
              onReorder: (o, n) => logic.onItemReorder(id, o, n),
            );
          },
          taskHandler: (task) {
            logic.appLogic.backstage.addTask(task);
          },
          fileHandlerBuilder: (name, data) {
            return Placeholder();
          },
        );
      },
    );
  }
}
