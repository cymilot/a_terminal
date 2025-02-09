import 'package:a_terminal/logic.dart';
import 'package:a_terminal/models/terminal.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/debug.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/storage.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FormLogic extends ChangeNotifier {
  FormLogic({
    required this.context,
    this.queryParams,
    this.tabController,
  });

  final BuildContext context;
  final Map<String, String>? queryParams;
  final TabController? tabController;

  final formKey = GlobalKey<FormState>();
  FormState? get form => formKey.currentState;
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();
  List<String> get shells => context.read<AppLogic>().shells;

  final canPop = ValueNotifier(false);
  final Map<String, ValueNotifier> controllers = {};

  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (result == null) {
      _resumePop(didPop);
      return;
    }
    if (form?.validate() != true) {
      return;
    }
    final type = queryParams?['type'];
    final key = queryParams?['key'];
    switch (type) {
      case 'local':
        _saveLocalData(key);
        break;
      case 'remote':
        _saveRemoteData(key);
        break;
    }
    _resumePop(didPop);
  }

  List<Widget> genForm() {
    if (queryParams != null) {
      TerminalModel? termModel;
      if (queryParams?['key'] != null) {
        termModel =
            Hive.box<TerminalModel>(boxKeyTerminal).get(queryParams?['key']);
      }
      if (termModel != null) {
        scaffoldLogic.activated.removeWhere(
            (e) => e.terminalData.terminalKey == queryParams?['key']);
      }
      if (queryParams?['type'] == 'local') {
        final model = termModel as LocalTerminalModel?;
        return _local(model).map((e) => e.buildWidget()).toList();
      }
      if (queryParams?['type'] == 'remote') {
        final model = termModel as RemoteTerminalModel?;
        return _remote(tabController!, model)
            .map((e) => e.buildWidget())
            .toList();
      }
    }
    return [];
  }

  TextEditingController genController(String key, String? defaultValue) {
    final controller = (controllers[key] ??=
        TextEditingController(text: defaultValue)) as TextEditingController;
    return controller;
  }

  ValueNotifier<T> genValueNotifier<T>(String key, T defaultValue) {
    final controller = (controllers[key] ??= ValueNotifier<T>(defaultValue))
        as ValueNotifier<T>;
    return controller;
  }

  String? _valiator(String label, String? value) {
    if (value == null || value.isEmpty) {
      return 'inRequired'.tr(context, [label.tr(context)]);
    }
    return null;
  }

  List<FormBlock> _local([LocalTerminalModel? model]) {
    return [
      FormBlock([
        // name
        FieldConfig.edit(
          iconData: Icons.sell,
          labelText: 'termName'.tr(context),
          controller: genController(
            'termName',
            model?.terminalName,
          ),
          validator: (value) => _valiator('termName', value),
        ),
        // shell
        FieldConfig.menu(
          iconData: Icons.terminal,
          labelText: 'termShell'.tr(context),
          valueNotifier: genValueNotifier(
            'termShell',
            model?.terminalShell ?? shells.first,
          ),
          menuItems: shells,
        ),
      ]),
    ];
  }

  List<FormBlock> _remote(TabController tabController,
      [RemoteTerminalModel? model]) {
    switch (model?.terminalSubType) {
      case RemoteTerminalType.ssh:
        tabController.index = 0;
        break;
      case RemoteTerminalType.telnet:
        tabController.index = 1;
        break;
      case _:
        break;
    }
    return [
      FormBlock([
        // name
        FieldConfig.edit(
          iconData: Icons.sell,
          labelText: 'termName'.tr(context),
          controller: genController(
            'termName',
            model?.terminalName,
          ),
          validator: (value) => _valiator('termName', value),
        ),
        // host
        FieldConfig.edit(
          iconData: Icons.public,
          labelText: 'termHost'.tr(context),
          controller: genController(
            'termHost',
            model?.terminalHost,
          ),
          validator: (value) => _valiator('termHost', value),
        ),
      ]),
      FormBlock([
        // tab: ssh, telnet
        FieldConfig.tab(
          tabs: ['SSH', 'Telnet'],
          tabController: tabController,
          tabChildren: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ssh port
                FieldConfig.edit(
                  iconData: Icons.lan,
                  labelText: 'termPort'.tr(context),
                  controller: genController(
                    'termSSHPort',
                    _shouldUseDefault(model, RemoteTerminalType.ssh)
                        ? model?.terminalPort.toString()
                        : '22',
                  ),
                  validator: (value) => _valiator('termPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // ssh username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'termUser'.tr(context),
                  controller: genController(
                    'termSSHUser',
                    _shouldUseDefault(model, RemoteTerminalType.ssh)
                        ? model?.terminalUser
                        : null,
                  ),
                  validator: (value) => _valiator('termUser', value),
                ),
                // ssh password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'termPass'.tr(context),
                  controller: genController(
                    'termSSHPass',
                    _shouldUseDefault(model, RemoteTerminalType.ssh)
                        ? model?.terminalPass
                        : null,
                  ),
                  obscureNotifier: genValueNotifier(
                    'termSSHPassObscure',
                    true,
                  ),
                ),
              ].map((e) => e.buildWidget()).toList(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // telnet port
                FieldConfig.edit(
                  iconData: Icons.lan,
                  labelText: 'termPort'.tr(context),
                  controller: genController(
                    'termTelnetPort',
                    _shouldUseDefault(model, RemoteTerminalType.telnet)
                        ? model?.terminalPort.toString()
                        : '23',
                  ),
                  validator: (value) => _valiator('termPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // telnet username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'termUser'.tr(context),
                  controller: genController(
                    'termTelnetUser',
                    _shouldUseDefault(model, RemoteTerminalType.telnet)
                        ? model?.terminalUser
                        : null,
                  ),
                  validator: (value) => _valiator('termUser', value),
                ),
                // telnet password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'termPass'.tr(context),
                  controller: genController(
                    'termTelnetPass',
                    _shouldUseDefault(model, RemoteTerminalType.telnet)
                        ? model?.terminalPass
                        : null,
                  ),
                  obscureNotifier: genValueNotifier(
                    'termTelnetPassObscure',
                    true,
                  ),
                ),
              ].map((e) => e.buildWidget()).toList(),
            ),
          ],
        ),
      ]),
    ];
  }

  bool _shouldUseDefault(RemoteTerminalModel? model, RemoteTerminalType t) {
    if (model?.terminalSubType == t) {
      return true;
    }
    return false;
  }

  void _resumePop(bool didPop) {
    if (!didPop) {
      canPop.value = true;
      scaffoldLogic.navigator?.pop();
    }
  }

  void _saveLocalData([String? rKey]) {
    final termName = controllers['termName'] as TextEditingController;
    final termShell = controllers['termShell'] as ValueNotifier<String>;

    logger.d('Form data:'
        ' type: local,'
        ' termName: ${termName.text},'
        ' termShell: ${termShell.value}.');

    final key = rKey ?? uuid.v1();
    Hive.box<TerminalModel>(boxKeyTerminal).put(
      key,
      LocalTerminalModel(
        terminalKey: key,
        terminalName: termName.text,
        terminalShell: termShell.value,
      ),
    );
  }

  void _saveRemoteData([String? rKey]) {
    final termName = controllers['termName'] as TextEditingController;
    final termSubType = tabController!.index;
    final termHost = controllers['termHost'] as TextEditingController;

    late final TextEditingController termPort;
    late final TextEditingController termUser;
    late final TextEditingController termPass;

    switch (RemoteTerminalType.values[termSubType]) {
      case RemoteTerminalType.ssh:
        termPort = controllers['termSSHPort'] as TextEditingController;
        termUser = controllers['termSSHUser'] as TextEditingController;
        termPass = controllers['termSSHPass'] as TextEditingController;
      case RemoteTerminalType.telnet:
        termPort = controllers['termTelnetPort'] as TextEditingController;
        termUser = controllers['termTelnetUser'] as TextEditingController;
        termPass = controllers['termTelnetPass'] as TextEditingController;
    }

    logger.d('Form data:'
        ' type: remote,'
        ' termName: ${termName.text},'
        ' termSubType: $termSubType,'
        ' termHost: ${termHost.text},'
        ' termPort: ${termPort.text},'
        ' termUser: ${termUser.text},'
        ' termPass: ${termPass.text}.');

    final key = rKey ?? uuid.v1();
    Hive.box<TerminalModel>(boxKeyTerminal).put(
      key,
      RemoteTerminalModel(
        terminalKey: key,
        terminalName: termName.text,
        terminalSubType: RemoteTerminalType.values[termSubType],
        terminalHost: termHost.text,
        terminalPort: int.parse(termPort.text),
        terminalUser: termUser.text,
        terminalPass: termPass.text,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    canPop.dispose();
  }
}

class FormBlock {
  FormBlock(this.fields);

  final List<FieldConfig> fields;

  Widget buildWidget() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: fields.map((e) => e.buildWidget()).toList(),
      ),
    );
  }
}

class FieldConfig {
  FieldConfig._({
    this.iconData,
    this.labelText,
    this.controller,
    this.obscureNotifier,
    this.validator,
    this.inputFormatters,
    this.menuItems,
    this.valueNotifier,
    this.tabs,
    this.tabController,
    this.tabChildren,
  }) : assert(tabs?.length == tabChildren?.length &&
            tabs?.length == tabController?.length);

  FieldConfig.edit({
    required IconData iconData,
    required String labelText,
    required TextEditingController controller,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    ValueNotifier<bool>? obscureNotifier,
  }) : this._(
          iconData: iconData,
          labelText: labelText,
          controller: controller,
          validator: validator,
          inputFormatters: inputFormatters,
          obscureNotifier: obscureNotifier,
        );

  FieldConfig.menu({
    required IconData iconData,
    required String labelText,
    required ValueNotifier<String> valueNotifier,
    required List<String> menuItems,
  }) : this._(
          iconData: iconData,
          labelText: labelText,
          valueNotifier: valueNotifier,
          menuItems: menuItems,
        );

  FieldConfig.tab({
    required List<String> tabs,
    required TabController tabController,
    required List<Widget> tabChildren,
  }) : this._(
          tabs: tabs,
          tabController: tabController,
          tabChildren: tabChildren,
        );

  final IconData? iconData;
  final String? labelText;

  final TextEditingController? controller;
  final ValueNotifier<bool>? obscureNotifier;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  final List<String>? menuItems;
  final ValueNotifier<String>? valueNotifier;

  final List<String>? tabs;
  final TabController? tabController;
  final List<Widget>? tabChildren;

  Widget buildWidget() {
    // menu
    if (valueNotifier != null && menuItems != null) {
      return ListTile(
        leading: Icon(iconData),
        title: SizedBox(
          height: 48.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(labelText!),
          ),
        ),
        trailing: SizedBox(
          width: 72.0,
          child: ValueListenableBuilder(
            valueListenable: valueNotifier!,
            builder: (context, value, _) {
              return DropdownButton<String>(
                underline: const SizedBox(),
                alignment: Alignment.center,
                value: value,
                items: menuItems!
                    .map((item) => DropdownMenuItem(
                          value: item.replaceAll('.exe', ''),
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (newValue) => valueNotifier!.value = newValue!,
              );
            },
          ),
        ),
      );
    }

    // tab view
    if (tabController != null && tabChildren != null) {
      return AppAdaptiveTabBarView(
        tabs: tabs!,
        tabController: tabController!,
        children: tabChildren!,
      );
    }

    // obscure edit
    if (obscureNotifier != null) {
      return ValueListenableBuilder(
        valueListenable: obscureNotifier!,
        builder: (context, obscure, _) {
          return ListTile(
            leading: Icon(iconData),
            title: TextFormField(
              decoration: InputDecoration(labelText: labelText),
              obscureText: obscure,
              controller: controller,
            ),
            trailing: IconButton(
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => obscureNotifier!.value = !obscureNotifier!.value,
            ),
          );
        },
      );
    }

    // edit
    return ListTile(
      leading: Icon(iconData),
      title: TextFormField(
        decoration: InputDecoration(labelText: labelText),
        controller: controller,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
