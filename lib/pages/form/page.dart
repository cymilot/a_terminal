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
        queryParams: widget.queryParams,
        tabController: _getTab(),
      ),
      dispose: (context, logic) => logic.dispose(),
      builder: (context, _) {
        final logic = context.read<FormLogic>();
        return ValueListenableBuilder(
          valueListenable: logic.canPop,
          builder: (context, canPop, child) {
            return Form(
              key: logic.formKey,
              canPop: canPop,
              onPopInvokedWithResult: logic.onPopInvokedWithResult,
              child: child!,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0),
            child: ListView(
              children: logic.genForm(),
            ),
          ),
        );
      },
    );
  }

  TabController? _getTab() {
    if (widget.queryParams != null && widget.queryParams?['type'] == 'remote') {
      return _remoteTab;
    }
    return null;
  }
}
