import 'package:a_terminal/consts.dart';
import 'package:a_terminal/logic.dart';
import 'package:a_terminal/hive_object/client.dart';
import 'package:a_terminal/pages/scaffold/logic.dart';
import 'package:a_terminal/utils/extension.dart';
import 'package:a_terminal/widgets/tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FormLogic {
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
  String? get action => queryParams?['action'];
  String? get type => queryParams?['type'];
  String? get key => queryParams?['key'];

  final canPop = ValueNotifier(false);

  final Map<String, ValueNotifier> controllers = {};

  void onPopInvokedWithResult(bool didPop, Object? result) {
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

  List<Widget> genForm() {
    if (queryParams == null) {
      return [];
    }
    late final ClientData? clientData;
    if (action != null && action == 'edit') {
      clientData = Hive.box<ClientData>(boxClient).get(key);
      scaffoldLogic.activated.removeWhere((e) => e.clientData.clientKey == key);
      if (type == 'local') {
        return _local(clientData as LocalClientData?)
            .map((e) => e.buildWidget())
            .toList();
      } else if (type == 'remote' && tabController != null) {
        return _remote(tabController!, clientData as RemoteClientData?)
            .map((e) => e.buildWidget())
            .toList();
      }
    } else if (action != null && action == 'create') {
      if (type == 'local') {
        return _local().map((e) => e.buildWidget()).toList();
      } else if (type == 'remote' && tabController != null) {
        return _remote(tabController!).map((e) => e.buildWidget()).toList();
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

  String? _validator(String label, String? value) {
    if (value == null || value.isEmpty) {
      return 'isRequired'.tr(context, {'name': label.tr(context)});
    }
    return null;
  }

  List<FormBlock> _local([LocalClientData? model]) {
    return [
      FormBlock([
        // name
        FieldConfig.edit(
          iconData: Icons.sell,
          labelText: 'terminalName'.tr(context),
          controller: genController(
            'terminalName',
            model?.clientName,
          ),
          validator: (value) => _validator('terminalName', value),
        ),
        // shell
        FieldConfig.menu(
          iconData: Icons.terminal,
          labelText: 'terminalShell'.tr(context),
          valueNotifier: genValueNotifier(
            'terminalShell',
            model?.clientShell ?? shells.first,
          ),
          menuItems: shells,
        ),
      ]),
    ];
  }

  List<FormBlock> _remote(TabController tabController,
      [RemoteClientData? model]) {
    switch (model?.remoteClientType) {
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
          controller: genController(
            'terminalName',
            model?.clientName,
          ),
          validator: (value) => _validator('terminalName', value),
        ),
        // host
        FieldConfig.edit(
          iconData: Icons.public,
          labelText: 'terminalHost'.tr(context),
          controller: genController(
            'terminalHost',
            model?.clientHost,
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
                  controller: genController(
                    'terminalSSHPort',
                    _shouldUseDefault(model, RemoteClientType.ssh)
                        ? model?.clientPort.toString()
                        : '22',
                  ),
                  validator: (value) => _validator('terminalPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // ssh username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'terminalUser'.tr(context),
                  controller: genController(
                    'terminalSSHUser',
                    _shouldUseDefault(model, RemoteClientType.ssh)
                        ? model?.clientUser
                        : null,
                  ),
                  validator: (value) => _validator('terminalUser', value),
                ),
                // ssh password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'terminalPass'.tr(context),
                  controller: genController(
                    'terminalSSHPass',
                    _shouldUseDefault(model, RemoteClientType.ssh)
                        ? model?.clientPass
                        : null,
                  ),
                  obscureNotifier: genValueNotifier(
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
                  controller: genController(
                    'terminalTelnetPort',
                    _shouldUseDefault(model, RemoteClientType.telnet)
                        ? model?.clientPort.toString()
                        : '23',
                  ),
                  validator: (value) => _validator('terminalPort', value),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                // telnet username
                FieldConfig.edit(
                  iconData: Icons.person,
                  labelText: 'terminalUser'.tr(context),
                  controller: genController(
                    'terminalTelnetUser',
                    _shouldUseDefault(model, RemoteClientType.telnet)
                        ? model?.clientUser
                        : null,
                  ),
                  validator: (value) => _validator('terminalUser', value),
                ),
                // telnet password
                FieldConfig.edit(
                  iconData: Icons.password,
                  labelText: 'terminalPass'.tr(context),
                  controller: genController(
                    'terminalTelnetPass',
                    _shouldUseDefault(model, RemoteClientType.telnet)
                        ? model?.clientPass
                        : null,
                  ),
                  obscureNotifier: genValueNotifier(
                    'terminalTelnetPassObscure',
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

  bool _shouldUseDefault(RemoteClientData? model, RemoteClientType type) {
    if (model?.remoteClientType == type) {
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

    // logger.d('Form data:'
    //     ' type: local,'
    //     ' terminalName: ${terminalName.text},'
    //     ' terminalShell: ${terminalShell.value}.');

    final resultkey = dataKey ?? uuid.v1();
    Hive.box<ClientData>(boxClient).put(
      resultkey,
      LocalClientData(
        clientKey: resultkey,
        clientName: terminalName.text,
        clientShell: terminalShell.value,
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

    // logger.d('Form data:'
    //     ' type: remote,'
    //     ' terminalName: ${terminalName.text},'
    //     ' terminalSubType: $terminalSubType,'
    //     ' terminalHost: ${terminalHost.text},'
    //     ' terminalPort: ${terminalPort.text},'
    //     ' terminalUser: ${terminalUser.text},'
    //     ' terminalPass: ${terminalPass.text}.');

    final resultKey = dataKey ?? uuid.v1();
    Hive.box<ClientData>(boxClient).put(
      resultKey,
      RemoteClientData(
        clientKey: resultKey,
        clientName: terminalName.text,
        remoteClientType: RemoteClientType.values[terminalSubType],
        clientHost: terminalHost.text,
        clientPort: int.parse(terminalPort.text),
        clientUser: terminalUser.text,
        clientPass: terminalPass.text,
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
                      width: 96.0,
                      height: 40.0,
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
              // return DropdownButton<String>(
              //   icon: const SizedBox.shrink(),
              //   value: value,
              //   items: menuItems!
              //       .map((item) => DropdownMenuItem(
              //             value: item,
              //             child: Text(
              //               item,
              //               overflow: TextOverflow.ellipsis,
              //             ),
              //           ))
              //       .toList(),
              //   onChanged: (newValue) => valueNotifier!.value = newValue!,
              // );
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
