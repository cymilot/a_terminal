import 'package:a_terminal/pages/form/logic.dart';
import 'package:a_terminal/router/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormPage extends StatefulWidget {
  const FormPage({
    super.key,
    this.args,
  });

  final Object? args;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with SingleTickerProviderStateMixin {
  late final FormArgs? args;
  late final TabController _remoteTab;

  @override
  void initState() {
    super.initState();
    if (widget.args != null) {
      args = widget.args as FormArgs;
    } else {
      args = null;
    }
    if (args != null && args?.subName == 'remote') {
      _remoteTab = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (args != null && args?.subName == 'remote') {
      _remoteTab.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormLogic(
        context: context,
        args: args,
        tabController: _getTab(),
      ),
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
    if (args != null && args?.subName == 'remote') {
      return _remoteTab;
    }
    return null;
  }
}
