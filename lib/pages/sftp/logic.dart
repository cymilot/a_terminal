import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/manage.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class SftpLogic {
  SftpLogic(this.context);

  final BuildContext context;

  Box<ClientData> get clientBox => Hive.box<ClientData>(boxClient);

  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  NavigatorState? get rootNavigator => scaffoldLogic.rootNavigator;
  ValueNotifier<int> get singleSftpIndex => scaffoldLogic.singleSftpIndex;
  ListenableList<SftpSession> get singleSftp => scaffoldLogic.singleSftp;
  List<RemoteClientData> get sshClientBox => clientBox.values
      .whereType<RemoteClientData>()
      .where((e) => e.remoteClientType == RemoteClientType.ssh)
      .toList();

  void onTapAddSftp() async {
    final result = await showDialog<RemoteClientData>(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 384.0,
            height: 384.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ListView.builder(
                  itemCount: sshClientBox.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(sshClientBox[index].clientName),
                      onTap: () => rootNavigator?.pop(sshClientBox[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      try {
        final sftp = await createSftpClient(
          result.clientName,
          result.clientHost,
          result.clientPort,
          result.clientUser!,
          result.clientPass!,
        );
        singleSftp.add(sftp);
        singleSftpIndex.value = singleSftp.length - 1;
      } catch (e) {
        toastification.show(
          type: ToastificationType.error,
          autoCloseDuration: kBackDuration,
          animationDuration: kAnimationDuration,
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          title: Text('$e'),
          alignment: Alignment.bottomCenter,
          style: ToastificationStyle.minimal,
        );
      }
    }
  }

  void onTabItemSelected(int index) => singleSftpIndex.value = index;

  void onTabItemRemoved(int index) {
    final client = singleSftp.removeAt(index);
    client.close();
    final newIndex = index - 1;
    singleSftpIndex.value = newIndex >= 0 ? newIndex : 0;
  }

  void onTabReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final client = singleSftp.removeAt(oldIndex);
    singleSftp.insert(newIndex, client);
    singleSftpIndex.value = newIndex;
  }

  List<Widget> genTabItems() {
    return singleSftp.map((e) {
      return AppDraggableTab(
        key: e.key,
        label: Text(e.name),
      );
    }).toList();
  }

  void dispose() {}
}
