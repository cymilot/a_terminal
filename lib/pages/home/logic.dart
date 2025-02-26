import 'package:a_terminal/consts.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/hive_object/settings.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomeLogic with DiagnosticableTreeMixin {
  HomeLogic(this.context);

  final BuildContext context;

  Box<ClientData> get terminalBox => Hive.box<ClientData>(boxClient);
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  ValueNotifier<SettingsData> get settings =>
      context.read<AppLogic>().currentSettings;

  Widget genViewItem(int index, Box<ClientData> box, List<String> selected) {
    late final GestureTapCallback onTap;
    late final GestureLongPressCallback onLongPress;

    final item = box.getAt(index)!;
    final type = item.clientType;
    final info = switch (type) {
      ClientType.local => (item as LocalClientData).clientShell,
      ClientType.remote => (item as RemoteClientData).remoteClientType.name,
    };
    final count = scaffoldLogic.activated
        .where((p0) => p0.clientData.clientKey == item.clientKey)
        .length;

    onTap = () {
      if (selected.contains(item.clientKey)) {
        scaffoldLogic.selected.remove(item.clientKey);
      } else if (selected.isNotEmpty) {
        scaffoldLogic.selected.add(item.clientKey);
      } else {
        scaffoldLogic.activated.add(ActivatedClient(item));
        scaffoldLogic.tabIndex.value = scaffoldLogic.activated.length - 1;
        scaffoldLogic.navigator?.pushUri('/view');
      }
    };
    onLongPress = () {
      scaffoldLogic.selected.add(item.clientKey);
    };

    return ListTile(
      title: Text(item.clientName),
      subtitle: Text('${type.name.tr(context)}/$info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          const SizedBox(width: 16.0),
          IconButton(
            onPressed: () => scaffoldLogic.navigator?.pushUri(
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
      selected: selected.contains(item.clientKey),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  void dispose() {}
}
