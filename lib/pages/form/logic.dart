import 'package:a_terminal/consts.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/utils/listenable.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FormLogic with DiagnosticableTreeMixin {
  FormLogic({
    required this.context,
    this.tabController,
  });

  final BuildContext context;
  final TabController? tabController;

  final formKey = GlobalKey<FormState>();
  FormState? get form => formKey.currentState;

  AppLogic get appLogic => context.read<AppLogic>();
  ScaffoldLogic get scaffoldLogic => context.read<ScaffoldLogic>();

  List<String> get shells => appLogic.shells;

  ListenableList<ActivatedClient> get activated => scaffoldLogic.activated;

  Box<ClientData> get box => Hive.box<ClientData>(boxClient);

  final canPop = ValueNotifier(false);
  final controllers = <String, ValueNotifier>{};

  void onPopInvokedWithResult(
    bool didPop,
    Object? result,
    String? type,
    String? key,
  ) {
    if (result == null) {
      _resumePop(didPop);
      return;
    }
    if (form?.validate() != true) return;
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

  List<Widget> localBuilder([String? key]) {
    final model = key != null ? box.get(key) as LocalClientData? : null;
    return [
      FormBlock([
        // name
        FieldConfig.edit(
          iconData: Icons.sell,
          labelText: 'terminalName'.tr(context),
          controller: _genController(
            'terminalName',
            model?.name,
          ),
          validator: (value) => _validator('terminalName', value),
        ),
        // shell
        FieldConfig.menu(
          iconData: Icons.terminal,
          labelText: 'terminalShell'.tr(context),
          valueNotifier: _genValueNotifier(
            'terminalShell',
            model?.shell ?? shells.first,
          ),
          menuItems: shells,
        ),
      ]),
    ].map((e) => e.buildWidget()).toList();
  }

  List<Widget> remoteBuilder(TabController tabController, [String? key]) {
    final model = key != null ? box.get(key) as RemoteClientData? : null;
    switch (model?.rType) {
      case RemoteClientType.ssh:
        tabController.index = 0;
        break;
      case RemoteClientType.telnet:
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
          labelText: 'terminalName'.tr(context),
          controller: _genController(
            'terminalName',
            model?.name,
          ),
          validator: (value) => _validator('terminalName', value),
        ),
        // host
        FieldConfig.edit(
          iconData: Icons.public,
          labelText: 'terminalHost'.tr(context),
          controller: _genController(
            'terminalHost',
            model?.host,
          ),
          validator: (value) => _validator('terminalHost', value),
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
                  labelText: 'terminalPort'.tr(context),
                  controller: _genController(
                    'terminalSSHPort',
                    _getDefault(model, RemoteClientType.ssh)
                        ? model?.port.toString()
                        : '22',
                  ),
                  validator: (value) => _validator('terminalPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // ssh username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'terminalUser'.tr(context),
                  controller: _genController(
                    'terminalSSHUser',
                    _getDefault(model, RemoteClientType.ssh)
                        ? model?.user
                        : null,
                  ),
                  validator: (value) => _validator('terminalUser', value),
                ),
                // ssh password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'terminalPass'.tr(context),
                  controller: _genController(
                    'terminalSSHPass',
                    _getDefault(model, RemoteClientType.ssh)
                        ? model?.pass
                        : null,
                  ),
                  obscureNotifier: _genValueNotifier(
                    'terminalSSHPassObscure',
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
                  labelText: 'terminalPort'.tr(context),
                  controller: _genController(
                    'terminalTelnetPort',
                    _getDefault(model, RemoteClientType.telnet)
                        ? model?.port.toString()
                        : '23',
                  ),
                  validator: (value) => _validator('terminalPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // telnet username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'terminalUser'.tr(context),
                  controller: _genController(
                    'terminalTelnetUser',
                    _getDefault(model, RemoteClientType.telnet)
                        ? model?.user
                        : null,
                  ),
                  validator: (value) => _validator('terminalUser', value),
                ),
                // telnet password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'terminalPass'.tr(context),
                  controller: _genController(
                    'terminalTelnetPass',
                    _getDefault(model, RemoteClientType.telnet)
                        ? model?.pass
                        : null,
                  ),
                  obscureNotifier: _genValueNotifier(
                    'terminalTelnetPassObscure',
                    true,
                  ),
                ),
              ].map((e) => e.buildWidget()).toList(),
            ),
          ],
        ),
      ]),
    ].map((e) => e.buildWidget()).toList();
  }

  TextEditingController _genController(String key, String? defaultValue) {
    final controller = (controllers[key] ??=
        TextEditingController(text: defaultValue)) as TextEditingController;
    return controller;
  }

  ValueNotifier<T> _genValueNotifier<T>(String key, T defaultValue) {
    final controller = (controllers[key] ??= ValueNotifier<T>(defaultValue))
        as ValueNotifier<T>;
    return controller;
  }

  String? _validator(String label, String? value) {
    if (value == null || value.isEmpty) {
      return 'isRequired'.tr(context, {'name': label.tr(context)});
    }
    return null;
  }

  bool _getDefault(RemoteClientData? model, RemoteClientType type) {
    if (model?.rType == type) {
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

  void _saveLocalData([String? dataKey]) {
    final terminalName = controllers['terminalName'] as TextEditingController;
    final terminalShell = controllers['terminalShell'] as ValueNotifier<String>;

    final uuid = dataKey ?? uuidGenerator.v1();
    Hive.box<ClientData>(boxClient).put(
      uuid,
      LocalClientData(
        uuid: uuid,
        name: terminalName.text,
        shell: terminalShell.value,
      ),
    );
  }

  void _saveRemoteData([String? dataKey]) {
    final terminalName = controllers['terminalName'] as TextEditingController;
    final terminalSubType = tabController!.index;
    final terminalHost = controllers['terminalHost'] as TextEditingController;

    late final TextEditingController terminalPort;
    late final TextEditingController terminalUser;
    late final TextEditingController terminalPass;

    switch (RemoteClientType.values[terminalSubType]) {
      case RemoteClientType.ssh:
        terminalPort = controllers['terminalSSHPort'] as TextEditingController;
        terminalUser = controllers['terminalSSHUser'] as TextEditingController;
        terminalPass = controllers['terminalSSHPass'] as TextEditingController;
      case RemoteClientType.telnet:
        terminalPort =
            controllers['terminalTelnetPort'] as TextEditingController;
        terminalUser =
            controllers['terminalTelnetUser'] as TextEditingController;
        terminalPass =
            controllers['terminalTelnetPass'] as TextEditingController;
    }

    final uuid = dataKey ?? uuidGenerator.v1();
    Hive.box<ClientData>(boxClient).put(
      uuid,
      RemoteClientData(
        uuid: uuid,
        name: terminalName.text,
        rType: RemoteClientType.values[terminalSubType],
        host: terminalHost.text,
        port: int.parse(terminalPort.text),
        user: terminalUser.text,
        pass: terminalPass.text,
      ),
    );
  }

  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    canPop.dispose();
  }

  @override
  String toStringShort() => '''
FormLogic(
  canPop: ${canPop.value},
  controllers: ${controllers.values.map((e) => e.value).toList()},
)''';
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
          width: 128.0,
          child: ValueListenableBuilder(
            valueListenable: valueNotifier!,
            builder: (context, value, _) {
              return MenuAnchor(
                  style: MenuStyle(alignment: Alignment(-0.85, 0.0)),
                  builder: (_, controller, __) {
                    return SizedBox(
                      width: kSelectionWidth,
                      height: kSelectionHeight,
                      child: Tooltip(
                        message: value,
                        child: FilledButton.tonal(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          child: Text(
                            value,
                            maxLines: 1,
                            textScaler: const TextScaler.linear(0.9),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    );
                  },
                  menuChildren: menuItems!
                      .map((e) => MenuItemButton(
                            onPressed: () {
                              valueNotifier!.value = e;
                            },
                            child: Text(e),
                          ))
                      .toList());
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
              tooltip: (obscureNotifier!.value ? 'showPass' : 'hidePass')
                  .tr(context),
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
