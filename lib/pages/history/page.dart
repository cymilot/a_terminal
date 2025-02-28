import 'package:a_terminal/pages/history/logic.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => HistoryLogic(context),
      dispose: (context, logic) => logic.dispose(),
      builder: (context, _) {
        final logic = context.read<HistoryLogic>();
        return ValueListenableBuilder(
          valueListenable: logic.history.listenable(),
          builder: (context, box, _) {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${box.getAt(index)?.name}'),
                  subtitle: Text('${box.getAt(index)?.timestamp}'),
                );
              },
            );
          },
        );
      },
    );
  }
}
