import 'package:a_terminal/pages/form/logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormPage extends StatefulWidget {
  const FormPage({
    super.key,
    this.queryParams,
  });

  final Map<String, String>? queryParams;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with SingleTickerProviderStateMixin {
  late final TabController _remoteTab;

  @override
  void initState() {
    super.initState();
    if (widget.queryParams != null && widget.queryParams?['type'] == 'remote') {
      _remoteTab = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.queryParams != null && widget.queryParams?['type'] == 'remote') {
      _remoteTab.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => FormLogic(
        context: context,
        tabController: _tabController,
      ),
      dispose: (context, logic) => logic.dispose(),
      lazy: true,
      builder: (context, _) {
        final logic = context.read<FormLogic>();

        return ValueListenableBuilder(
          valueListenable: logic.canPop,
          builder: (context, canPop, child) {
            return Form(
              key: logic.formKey,
              canPop: canPop,
              onPopInvokedWithResult: (canPop, result) {
                logic.onPopInvokedWithResult(
                  canPop,
                  result,
                  widget.queryParams?['type'],
                  widget.queryParams?['key'],
                );
              },
              child: child!,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
            child: ListView(
              children: _buildForm(
                logic.localBuilder,
                logic.remoteBuilder,
              ),
            ),
          ),
        );
      },
    );
  }

  TabController? get _tabController {
    if (widget.queryParams != null && widget.queryParams?['type'] == 'remote') {
      return _remoteTab;
    }
    return null;
  }

  List<Widget> _buildForm(
    List<Widget> Function([String?]) localBuilder,
    List<Widget> Function(TabController, [String?]) remoteBuilder,
  ) {
    if (widget.queryParams == null) {
      return [];
    }
    final action = widget.queryParams?['action'];
    final type = widget.queryParams?['type'];
    final key = widget.queryParams?['key'];
    if (action != null && action == 'edit') {
      if (type == 'local') {
        return localBuilder.call(key);
      } else if (type == 'remote' && _tabController != null) {
        return remoteBuilder.call(_tabController!, key);
      }
    } else if (action != null && action == 'create') {
      if (type == 'local') {
        return localBuilder.call();
      } else if (type == 'remote' && _tabController != null) {
        return remoteBuilder.call(_tabController!);
      }
    }
    return [];
  }
}
