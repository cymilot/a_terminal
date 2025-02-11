// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ATerminal';

  @override
  String get exitTip => 'Press once more to exit.';

  @override
  String get addNew => 'Add new';

  @override
  String terminal(String action, String type, int lower) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'create': 'Create ',
        'edit': 'Edit ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      lower,
      locale: localeName,
      one: ' t',
      other: 'T',
    );
    return '$_temp0$type${_temp1}erminal';
  }

  @override
  String get terminalName => 'Terminal name';

  @override
  String get terminalShell => 'Terminal shell';

  @override
  String get terminalHost => 'Terminal host';

  @override
  String get terminalPort => 'Terminal port';

  @override
  String get terminalUser => 'Terminal username';

  @override
  String get terminalPass => 'Terminal password';

  @override
  String get local => 'Local';

  @override
  String get remote => 'Remote';

  @override
  String isRequired(String name) {
    return '$name is required.';
  }

  @override
  String inSelecting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'no item',
    );
    return 'Selected $_temp0';
  }

  @override
  String get home => 'Home';

  @override
  String get emptyTerminal => 'No terminal';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get color => 'Color';

  @override
  String get systemColor => 'Use system accent color';

  @override
  String get switchColor => 'Select color';

  @override
  String get maxLines => 'Max lines';

  @override
  String get unknown => 'Unknown';

  @override
  String get back => 'Back';
}

/// The translations for English, as used in the United States (`en_US`).
class AppL10nEnUs extends AppL10nEn {
  AppL10nEnUs() : super('en_US');

  @override
  String get appTitle => 'ATerminal';

  @override
  String get exitTip => 'Press once more to exit.';

  @override
  String get addNew => 'Add new';

  @override
  String terminal(String action, String type, int lower) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'create': 'Create ',
        'edit': 'Edit ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.pluralLogic(
      lower,
      locale: localeName,
      one: ' t',
      other: 'T',
    );
    return '$_temp0$type${_temp1}erminal';
  }

  @override
  String get terminalName => 'Terminal name';

  @override
  String get terminalShell => 'Terminal shell';

  @override
  String get terminalHost => 'Terminal host';

  @override
  String get terminalPort => 'Terminal port';

  @override
  String get terminalUser => 'Terminal username';

  @override
  String get terminalPass => 'Terminal password';

  @override
  String get local => 'Local';

  @override
  String get remote => 'Remote';

  @override
  String isRequired(String name) {
    return '$name is required.';
  }

  @override
  String inSelecting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'no item',
    );
    return 'Selected $_temp0';
  }

  @override
  String get home => 'Home';

  @override
  String get emptyTerminal => 'No terminal';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get color => 'Color';

  @override
  String get systemColor => 'Use system accent color';

  @override
  String get switchColor => 'Select color';

  @override
  String get maxLines => 'Max lines';

  @override
  String get unknown => 'Unknown';

  @override
  String get back => 'Back';
}
