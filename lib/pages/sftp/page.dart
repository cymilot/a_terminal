import 'package:a_terminal/consts.dart';
import 'package:a_terminal/pages/sftp/logic.dart';
import 'package:a_terminal/utils/edit.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/foundation.dart';
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

        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth / 2 - 0.5,
                  child: _buildPanel(
                    tabIndex: logic.panel1Index,
                    items: logic.panel1Sessions,
                    onTabItemSelected: (index) => logic.onTabItemSelected(
                      logic.panel1Index,
                      index,
                    ),
                    onTabItemRemoved: (index) => logic.onTabItemRemoved(
                      logic.panel1Index,
                      logic.panel1Sessions,
                      index,
                    ),
                    onTabReorder: (oldIndex, newIndex) => logic.onTabReorder(
                      logic.panel1Index,
                      logic.panel1Sessions,
                      oldIndex,
                      newIndex,
                    ),
                    onIncrease: () => logic.onIncrease(
                      logic.panel1Index,
                      logic.panel1Sessions,
                    ),
                  ),
                ),
                Container(
                  width: 1.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: constraints.maxWidth / 2 - 0.5,
                  child: _buildPanel(
                    tabIndex: logic.panel2Index,
                    items: logic.panel2Sessions,
                    onTabItemSelected: (index) => logic.onTabItemSelected(
                      logic.panel2Index,
                      index,
                    ),
                    onTabItemRemoved: (index) => logic.onTabItemRemoved(
                      logic.panel2Index,
                      logic.panel2Sessions,
                      index,
                    ),
                    onTabReorder: (oldIndex, newIndex) => logic.onTabReorder(
                      logic.panel2Index,
                      logic.panel2Sessions,
                      oldIndex,
                      newIndex,
                    ),
                    onIncrease: () => logic.onIncrease(
                      logic.panel2Index,
                      logic.panel2Sessions,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPanel({
    required ValueListenable<int> tabIndex,
    required ValueListenable<List<AppFSSession>> items,
    required ValueChanged<int> onTabItemSelected,
    required ValueChanged<int> onTabItemRemoved,
    required ReorderCallback onTabReorder,
    required VoidCallback onIncrease,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge([tabIndex, items]),
      builder: (context, _) {
        return Column(
          children: [
            AppDraggableTabBar(
              items: _buildTabItems(context, items.value),
              selectedIndex: tabIndex.value,
              onItemSelected: onTabItemSelected,
              onItemRemoved: onTabItemRemoved,
              onReorder: onTabReorder,
              header: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: IconButton(
                    tooltip: 'addNew'.tr(context),
                    onPressed: onIncrease,
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
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: items.value.isNotEmpty
                    ? AppFSManagerPanel(
                        session: items.value[tabIndex.value],
                        refreshTooltip: 'refresh'.tr(context),
                        onOpenFile: (context, entity, data) => onOpenFile(
                          context,
                          entity,
                          data,
                          items.value[tabIndex.value].saveFile,
                        ),
                        onError: errorToast,
                      )
                    : Center(child: Text('emptyData'.tr(context))),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTabItems(BuildContext context, List<AppFSSession> items) {
    return items.map((e) {
      return AppDraggableTab(
        key: e.key,
        label: Text(e.name),
        tooltip: 'close'.tr(context),
      );
    }).toList();
  }
}
