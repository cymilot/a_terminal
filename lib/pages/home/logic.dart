import 'package:a_terminal/logic.dart';
import 'package:a_terminal/models/setting.dart';
import 'package:a_terminal/models/term.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/router/router.dart';
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

  ValueListenable<Box<TermModel>> get termBoxL =>
      Hive.box<TermModel>(term).listenable();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  LData<SettingModel> get settingL => context.read<AppLogic>().settingL;

  Widget genViewItem(int index, Box<TermModel> box) {
    late final GestureTapCallback onTap;
    late final GestureLongPressCallback onLongPress;

    final item = box.getAt(index)!;
    final type = item.termType;
    final info = switch (type) {
      TermType.local => (item as LocalTermModel).termShell,
      TermType.remote => (item as RemoteTermModel).termSubType.name,
    };
    final active = scaffoldLogic.activeTerms
        .where((p0) => p0.termData.termKey == item.termKey)
        .length;

    onTap = () {
      if (scaffoldLogic.selectedTerms.contains(item.termKey)) {
        scaffoldLogic.selectedTerms.remove(item.termKey);
      } else if (scaffoldLogic.selectedTerms.isNotEmpty) {
        scaffoldLogic.selectedTerms.add(item.termKey);
      } else {
        switch (type) {
          case TermType.local:
            final local = item as LocalTermModel;
            final shell = local.termShell;
            scaffoldLogic.activeTerms.add(ActiveTerm(
              key: UniqueKey(),
              termData: item,
              terminal: Terminal(
                maxLines: settingL.value.termMaxLines,
              ),
              onCreate: (terminal) => createPty(shell, terminal),
              onDestroy: (session) => (session as Pty).kill(),
            ));
            break;
          case TermType.remote:
            final remote = item as RemoteTermModel;
            final host = remote.termHost;
            final port = remote.termPort;
            final user = remote.termUser;
            final pwd = remote.termPass;
            scaffoldLogic.activeTerms.add(ActiveTerm(
              key: UniqueKey(),
              termData: item,
              terminal: Terminal(
                maxLines: settingL.value.termMaxLines,
              ),
              onCreate: (terminal) {
                switch (remote.termSubType) {
                  case RemoteTermType.ssh:
                    return createSSH(
                      host,
                      port,
                      user!,
                      pwd!,
                      terminal,
                    );
                  case RemoteTermType.telnet:
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
                switch (remote.termSubType) {
                  case RemoteTermType.ssh:
                    (session as SSHSession).close();
                    break;
                  case RemoteTermType.telnet:
                    (session as TelnetSession).close();
                    break;
                }
              },
            ));
            break;
        }
        scaffoldLogic.tabIndex.value = scaffoldLogic.activeTerms.length - 1;
        scaffoldLogic.navigator?.pushNamed(rActive);
      }
    };
    onLongPress = () {
      scaffoldLogic.selectedTerms.add(item.termKey);
    };

    return ListTile(
      title: Text(item.termName),
      subtitle: Text('${type.name.tr(context)}/$info'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active > 0)
            Text(
              '$active actived',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          const SizedBox(width: 16.0),
          IconButton(
            onPressed: () => scaffoldLogic.navigator?.pushNamed(
              rForm,
              arguments: FormArgs(
                subName: type.name,
                matchKey: item.termKey,
              ),
            ),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      selected: scaffoldLogic.selectedTerms.contains(item.termKey),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
