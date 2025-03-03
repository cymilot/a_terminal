import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomeLogic with DiagnosticableTreeMixin {
  HomeLogic(this.context);

  final BuildContext context;

  Box<ClientData> get terminalBox => Hive.box<ClientData>(boxClient);

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  AppLogic get appLogic => context.read<AppLogic>();

  Settings get settings => appLogic.settings;
  String get defaultPath => appLogic.defaultPath;
  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;
  ListenableList<String> get selected => scaffoldLogic.selected;
  ValueNotifier<int> get tabIndex => scaffoldLogic.tabIndex;
  NavigatorState? get navigator => scaffoldLogic.navigator;

  Widget genViewItem(BuildContext context, int index) {
    late final GestureTapCallback onTap;
    late final GestureLongPressCallback onLongPress;

    final item = terminalBox.getAt(index)!;
    final type = item.clientType;
    final info = switch (type) {
      ClientType.local => (item as LocalClientData).clientShell,
      ClientType.remote => (item as RemoteClientData).remoteClientType.name,
    };
    final count = activated
        .where((p0) => p0.clientData.clientKey == item.clientKey)
        .length;
    final selecting = selected.contains(item.clientKey);

    onTap = () {
      if (selecting) {
        selected.remove(item.clientKey);
      } else if (selected.isNotEmpty) {
        selected.add(item.clientKey);
      } else {
        activated.add(ActivatedClient(item, defaultPath));
        Hive.box<HistoryData>(boxHistory).add(HistoryData(
          item.clientName,
          DateTime.now().millisecondsSinceEpoch,
        ));
        tabIndex.value = activated.length - 1;
        navigator?.pushUri('/view');
      }
    };
    onLongPress = () {
      if (!selecting) {
        selected.add(item.clientKey);
      }
    };

    return ListTile(
      title: Text(item.clientName),
      subtitle: Text('${type.name.tr(context)}/$info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0) Text('$count'),
          const SizedBox(width: 16.0),
          IconButton(
            tooltip: 'edit'.tr(context),
            onPressed: () => navigator?.pushUri(
              '/home/form',
              queryParams: {
                'action': 'edit',
                'type': type.name,
                'key': item.key,
              },
            ),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      selected: selecting,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  void dispose() {}
}
