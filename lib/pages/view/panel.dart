import 'package:a_terminal/hive_object/client.dart';
import 'package:flutter/material.dart';

class SftpPanel extends StatelessWidget {
  const SftpPanel({
    super.key,
    required this.client,
    required this.extendedNotifier,
    required this.extendedDuration,
  });

  final ActivatedClient client;
  final ValueNotifier<bool> extendedNotifier;
  final Duration extendedDuration;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: extendedNotifier,
      builder: (context, extended, _) {
        return AnimatedSwitcher(
          duration: extendedDuration,
          child: extended
              ? Container(
                  width: 168.0,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow
                      .withValues(alpha: 0.38),
                  child: FutureBuilder(
                    future: Future.value(client.createSftp()),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (snapshot.hasData) {
                            return _buildPanel(snapshot.data!);
                          } else {
                            return const Center(child: Text('Not support.'));
                          }
                      }
                    },
                  ),
                )
              : const SizedBox.shrink(),
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildPanel(SftpManager manager) {
    manager.listDir();
    return ValueListenableBuilder(
      valueListenable: manager.lastDirResult,
      builder: (context, dir, _) {
        return ListView.builder(
          itemCount: dir.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                dir[index].filename,
                overflow: TextOverflow.clip,
              ),
              subtitle: Text(
                dir[index].longname,
                style: const TextStyle(fontSize: 11),
              ),
            );
          },
        );
      },
    );
  }
}
