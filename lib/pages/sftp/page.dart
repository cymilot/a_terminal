import 'package:a_terminal/pages/sftp/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/manage.dart';
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

        return _buildDashboard(logic);
      },
    );
  }

  Widget _buildDashboard(SftpLogic logic) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([
                logic.singleSftpIndex,
                logic.singleSftp,
              ]),
              builder: (context, _) => AppDraggableTabBar(
                items: logic.genTabItems(),
                selectedIndex: logic.singleSftpIndex.value,
                onItemSelected: logic.onTabItemSelected,
                onItemRemoved: logic.onTabItemRemoved,
                onReorder: logic.onTabReorder,
                footer: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: logic.onTapAddSftp,
                    icon: Icon(Icons.add),
                  ),
                ),
              ),
            ),
            Container(
              height: 1.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth / 2 - 0.5,
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        logic.singleSftpIndex,
                        logic.singleSftp,
                      ]),
                      builder: (context, _) {
                        if (logic.singleSftp.isNotEmpty) {
                          return FileManagerPanel(
                            session:
                                logic.singleSftp[logic.singleSftpIndex.value],
                            refreshButtonTooltip: 'refresh'.tr(context),
                          );
                        } else {
                          return Center(
                            child: Text('emptyTerminal'.tr(context)),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 1.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: constraints.maxWidth / 2 - 0.5,
                    child: FileManagerPanel(
                      session: LocalManagerSession(
                        'local',
                        initialPath: logic.defaultPath,
                      ),
                      refreshButtonTooltip: 'refresh'.tr(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
