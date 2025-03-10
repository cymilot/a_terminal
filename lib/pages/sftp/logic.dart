import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/widgets/panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SftpLogic with DiagnosticableTreeMixin {
  SftpLogic(this.context);

  final BuildContext context;

  Box<ClientData> get clientBox => Hive.box<ClientData>(boxClient);

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  String get defaultPath => appLogic.defaultPath;
  NavigatorState? get rootNavigator => scaffoldLogic.rootNavigator;

  ValueNotifier<int> get panel1Index => scaffoldLogic.panel1Index;
  ListenableList<AppFSSession> get panel1Sessions =>
      scaffoldLogic.panel1Sessions;

  ValueNotifier<int> get panel2Index => scaffoldLogic.panel2Index;
  ListenableList<AppFSSession> get panel2Sessions =>
      scaffoldLogic.panel2Sessions;

  List<ClientData> get sshClientData => clientBox.values
      .whereType<RemoteClientData>()
      .where((e) => e.rType == RemoteClientType.ssh)
      .toList();

  void onIncrease(
    ValueNotifier<int> panelIndex,
    ListenableList<AppFSSession> panelSessions,
  ) async {
    final result = await showDialog<_SessionInfo>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: kDialogWidth,
            height: kDialogHeight,
            child: Column(
              children: [
                ListTile(
                  title: Text('local'.tr(context)),
                  onTap: () => rootNavigator?.pop(_SessionInfo(
                    isLocal: true,
                    name: 'local'.tr(context),
                  )),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: sshClientData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(sshClientData[index].name),
                        onTap: () {
                          final info = sshClientData[index] as RemoteClientData;
                          rootNavigator?.pop(_SessionInfo(
                            isLocal: false,
                            name: info.name,
                            host: info.host,
                            port: info.port,
                            username: info.user,
                            password: info.pass,
                          ));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      late final AppFSSession? session;
      if (result.isLocal) {
        session = AppLocalFSSession(
          result.name,
          defaultPath,
        );
      } else {
        session = await createSftpClient(
          result.name,
          result.host!,
          result.port!,
          username: result.username!,
          password: result.password!,
          errorHandler: errorToast,
        );
      }
      if (session != null) {
        panelSessions.add(session);
        panelIndex.value = panelSessions.length - 1;
      }
    }
  }

  void onTabItemSelected(ValueNotifier<int> panelIndex, int index) =>
      panelIndex.value = index;

  void onTabItemRemoved(
    ValueNotifier<int> panelIndex,
    ListenableList<AppFSSession> panelSessions,
    int index,
  ) {
    final client = panelSessions.removeAt(index);
    client.dispose();
    final newIndex = index - 1;
    panelIndex.value = newIndex >= 0 ? newIndex : 0;
  }

  void onTabReorder(
    ValueNotifier<int> panelIndex,
    ListenableList<AppFSSession> panelSessions,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final client = panelSessions.removeAt(oldIndex);
    panelSessions.insert(newIndex, client);
    panelIndex.value = newIndex;
  }

  void dispose() {}
}

class _SessionInfo {
  _SessionInfo({
    required this.isLocal,
    required this.name,
    this.host,
    this.port,
    this.username,
    this.password,
  });

  final bool isLocal;
  final String name;
  final String? host;
  final int? port;
  final String? username;
  final String? password;

  @override
  bool operator ==(Object other) {
    return other is _SessionInfo &&
        other.isLocal == isLocal &&
        other.name == name &&
        other.host == host &&
        other.port == port &&
        other.username == username &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hashAll([
        isLocal,
        name,
        host,
        port,
        username,
        password,
      ]);
}
