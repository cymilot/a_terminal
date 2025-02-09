import 'package:a_terminal/logic.dart';
import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/connect.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:a_terminal/utils/telnet/session.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';

class HomeLogic with ChangeNotifier, DiagnosticableTreeMixin {
  HomeLogic({required this.context});

  final BuildContext context;

  ValueListenable<Box<TerminalModel>> get terminalBox =>
      Hive.box<TerminalModel>(boxKeyTerminal).listenable();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  ListenableData<SettingModel> get setting =>
      context.read<AppLogic>().currentSetting;

  Widget genViewItem(int index, Box<TerminalModel> box) {
    late final GestureTapCallback onTap;
    late final GestureLongPressCallback onLongPress;

    final item = box.getAt(index)!;
    final type = item.terminalType;
    final info = switch (type) {
      TerminalType.local => (item as LocalTerminalModel).terminalShell,
      TerminalType.remote => (item as RemoteTerminalModel).terminalSubType.name,
    };
    final active = scaffoldLogic.activated
        .where((p0) => p0.terminalData.terminalKey == item.terminalKey)
        .length;

    onTap = () {
      if (scaffoldLogic.selected.contains(item.terminalKey)) {
        scaffoldLogic.selected.remove(item.terminalKey);
      } else if (scaffoldLogic.selected.isNotEmpty) {
        scaffoldLogic.selected.add(item.terminalKey);
      } else {
        switch (type) {
          case TerminalType.local:
            final local = item as LocalTerminalModel;
            final shell = local.terminalShell;
            scaffoldLogic.activated.add(ActivatedTerminal(
              key: UniqueKey(),
              terminalData: item,
              terminal: Terminal(
                maxLines: setting.value.termMaxLines,
              ),
              onCreate: (terminal) => createPty(shell, terminal),
              onDestroy: (session) => (session as Pty).kill(),
            ));
            break;
          case TerminalType.remote:
            final remote = item as RemoteTerminalModel;
            final host = remote.terminalHost;
            final port = remote.terminalPort;
            final user = remote.terminalUser;
            final pwd = remote.terminalPass;
            scaffoldLogic.activated.add(ActivatedTerminal(
              key: UniqueKey(),
              terminalData: item,
              terminal: Terminal(
                maxLines: setting.value.termMaxLines,
              ),
              onCreate: (terminal) {
                switch (remote.terminalSubType) {
                  case RemoteTerminalType.ssh:
                    return createSSH(
                      host,
                      port,
                      user!,
                      pwd!,
                      terminal,
                    );
                  case RemoteTerminalType.telnet:
                    return createTelnet(
                      host,
                      port,
                      terminal,
                      username: user,
                      password: pwd,
                      printDebug: logger.d,
                    );
                }
              },
              onDestroy: (session) {
                switch (remote.terminalSubType) {
                  case RemoteTerminalType.ssh:
                    (session as SSHSession).close();
                    break;
                  case RemoteTerminalType.telnet:
                    (session as TelnetSession).close();
                    break;
                }
              },
            ));
            break;
        }
        scaffoldLogic.tabIndex.value = scaffoldLogic.activated.length - 1;
        scaffoldLogic.navigator?.pushNamed('/view');
      }
    };
    onLongPress = () {
      scaffoldLogic.selected.add(item.terminalKey);
    };

    return ListTile(
      title: Text(item.terminalName),
      subtitle: Text('${type.name.tr(context)}/$info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active > 0)
            Text(
              '$active',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          const SizedBox(width: 16.0),
          IconButton(
            onPressed: () => scaffoldLogic.navigator?.pushNamed('/home/form'),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      selected: scaffoldLogic.selected.contains(item.terminalKey),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
