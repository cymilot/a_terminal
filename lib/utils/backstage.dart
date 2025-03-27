import 'package:a_terminal/utils/listenable.dart';

// TODO
class AppBackstage {
  AppBackstage();

  final _tasks = ListenableList<List<Future<void> Function()>>();

  void addTask(List<Future<void> Function()> task) {
    _tasks.add(task);
  }
}
