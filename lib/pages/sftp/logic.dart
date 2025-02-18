import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SftpLogic {
  SftpLogic(this.context);

  final BuildContext context;

  Box<ClientData> get terminalBox => Hive.box<ClientData>(boxClient);
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  List<RemoteClientData> get sshBox => terminalBox.values
      .whereType<RemoteClientData>()
      .where((e) => e.remoteClientType == RemoteClientType.ssh)
      .toList();

  Widget genViewItem(int index) {
    return ListTile(
      title: Text(sshBox[index].clientName),
    );
  }

  void dispose() {}
}
