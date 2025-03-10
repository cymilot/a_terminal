import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/home/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => HomeLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<HomeLogic>();
        final theme = Theme.of(context);

        return ValueListenableBuilder(
          valueListenable: logic.clientBox.listenable(),
          builder: (context, box, _) {
            return AnimatedSwitcher(
              duration: kAnimationDuration,
              child: box.isEmpty
                  ? Center(
                      child: Text(
                        'emptyTerminal'.tr(context),
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListenableBuilder(
                      listenable: Listenable.merge([
                        logic.selected,
                        logic.activated,
                      ]),
                      builder: (context, _) {
                        return _buildListView(
                          box,
                          logic.selected.value,
                          logic.activated.value,
                          logic.onEdit,
                          logic.onTap,
                          logic.onLongPress,
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(
    Box<ClientData> box,
    List<String> selected,
    List<ActivatedClient> activated,
    void Function(String, dynamic) onEdit,
    void Function(ClientData) onTap,
    void Function(ClientData) onLongPress,
  ) {
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final item = box.getAt(index)!;
        final type = item.type;
        final info = switch (type) {
          ClientType.local => (item as LocalClientData).shell,
          ClientType.remote => (item as RemoteClientData).rType.name,
        };
        final count =
            activated.where((e) => e.clientData.key == item.key).length;
        final selecting = selected.contains(item.key);

        return ListTile(
          title: Text(item.name),
          subtitle: Text('${type.name.tr(context)}/$info'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count > 0) Text('$count'),
              const SizedBox(width: 16.0),
              IconButton(
                tooltip: 'edit'.tr(context),
                onPressed: () => onEdit(type.name, item.key),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          selected: selecting,
          onTap: () => onTap(item),
          onLongPress: () => onLongPress(item),
        );
      },
    );
  }
}
