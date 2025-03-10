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

  Box<ClientData> get clientBox => Hive.box<ClientData>(boxClient);
  Box<HistoryData> get historyBox => Hive.box<HistoryData>(boxHistory);

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  AppLogic get appLogic => context.read<AppLogic>();

  Settings get settings => appLogic.settings;
  String get defaultPath => appLogic.defaultPath;

  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;
  ListenableList<String> get selected => scaffoldLogic.selected;
  ValueNotifier<int> get tabIndex => scaffoldLogic.tabIndex;
  NavigatorState? get navigator => scaffoldLogic.navigator;

  void onEdit(String name, dynamic key) {
    activated.removeWhere((e) => e.clientData.key == key);
    navigator?.pushUri('/home/form', queryParams: {
      'action': 'edit',
      'type': name,
      'key': key,
    });
  }

  void onTap(ClientData item) {
    final selecting = selected.contains(item.key);

    if (selecting) {
      selected.remove(item.key);
    } else if (selected.isNotEmpty) {
      selected.add(item.key);
    } else {
      activated.add(ActivatedClient(item, defaultPath));
      historyBox.add(HistoryData(
        item.name,
        DateTime.now().millisecondsSinceEpoch,
      ));
      tabIndex.value = activated.length - 1;
      navigator?.pushUri('/view');
    }
  }

  void onLongPress(ClientData item) {
    final selecting = selected.contains(item.key);

    if (!selecting) {
      selected.add(item.key);
    }
  }

  @override
  String toStringShort() => '''HomeLogic()''';

  void dispose() {}
}
