import 'package:a_terminal/hive_object/history.dart';
import 'package:a_terminal/pages/history/logic.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// TODO
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => HistoryLogic(context),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<HistoryLogic>();

        return ValueListenableBuilder(
          valueListenable: logic.history.listenable(),
          builder: (context, box, _) {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) => _buildListTile(
                context,
                box.getAt(index),
                () => box.deleteAt(index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    HistoryData? data,
    VoidCallback onDeleted,
  ) {
    final dateTime = data != null
        ? DateTime.fromMillisecondsSinceEpoch(data.time).toString()
        : '';
    return ListTile(
      title: Text('${data?.name}'),
      subtitle: Text(dateTime),
      trailing: IconButton(
        onPressed: onDeleted,
        icon: Icon(Icons.delete),
      ),
    );
  }
}
