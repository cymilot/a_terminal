import 'package:a_terminal/consts.dart';
import 'package:a_terminal/hive_object/history.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HistoryLogic {
  HistoryLogic(this.context);

  final BuildContext context;

  final history = Hive.box<HistoryData>(boxHistory);

  Widget genViewItem(
      BuildContext context, HistoryData? data, void Function() onDeleted) {
    final dateTime = data != null
        ? DateTime.fromMillisecondsSinceEpoch(data.timestamp).toString()
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

  void dispose() {}
}
