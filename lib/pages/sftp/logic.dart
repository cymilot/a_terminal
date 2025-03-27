import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/extension.dart';
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

  NavigatorState? get rootNavigator => scaffoldLogic.rootNavigator;
  PanelController get controller => scaffoldLogic.panelController;

  List<RemoteClientData> get sftpClients => clientBox.values
      .whereType<RemoteClientData>()
      .where((e) => e.rType == RemoteClientType.ssh)
      .toList();

  void onItemSelected(int id, int index) => controller.changeIndexAt(id, index);

  void onItemRemoved(int id, int index) {
    final session = controller.removeSessionAt(id, index);
    session.dispose();
    if (controller.indexAt(id) >= index && controller.indexAt(id) != 0) {
      controller.changeIndexAt(id, controller.indexAt(id) - 1);
    }
  }

  void onItemReorder(int id, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final session = controller.removeSessionAt(id, oldIndex);
    controller.insertSessionAt(id, newIndex, session);
    controller.changeIndexAt(id, newIndex);
  }

  void onTapAdd(int id) => showDialog(
        context: context,
        builder: (context) {
          return _MyDialog(
            id: id,
            sftpClients: sftpClients,
            controller: controller,
            defaultPath: appLogic.defaultPath,
          );
        },
      );

  void dispose() {}
}

class _MyDialog extends StatelessWidget {
  const _MyDialog({
    required this.id,
    required this.sftpClients,
    required this.controller,
    required this.defaultPath,
  });

  final int id;
  final List<RemoteClientData> sftpClients;
  final PanelController controller;
  final String defaultPath;

  @override
  Widget build(BuildContext context) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    return Dialog(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth / 2,
            height: constraints.maxHeight / 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('local'.tr(context)),
                    onTap: () {
                      controller.addSessionAt(
                          id,
                          AppLocalFSSession(
                            name: 'local'.tr(context),
                            initialPath: defaultPath,
                          ));
                      rootNavigator.pop();
                    },
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sftpClients.length,
                      itemBuilder: (context, index) {
                        final data = sftpClients[index];
                        return ListTile(
                          title: Text(data.name),
                          onTap: () async {
                            final session = await createSftpClient(
                              data.name,
                              data.host,
                              data.port,
                              username: data.user!,
                              password: data.pass!,
                            );
                            if (session != null) {
                              controller.addSessionAt(id, session);
                            }
                            rootNavigator.pop();
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
      ),
    );
  }
}
