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
  String get local => 'Local';

  @override
  String get localCreate => 'Create local terminal';

  @override
  String get localEdit => 'Edit local terminal';

  @override
  String get remote => 'Remote';

  @override
  String get remoteCreate => 'Create remote terminal';

  @override
  String get remoteEdit => 'Edit remote terminal';

  @override
  String get termName => 'Terminal name';

  @override
  String get termShell => 'Shell';

  @override
  String get termHost => 'Host';

  @override
  String get termPort => 'Port';

  @override
  String get termUser => 'User';

  @override
  String get termPass => 'Password';

  @override
  String inRequired(String name) {
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
  String get noTerm => 'No terminal';

  @override
  String get term => 'Terminal';

  @override
  String get setting => 'Setting';

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get useSystemAccent => 'Use system accent';

  @override
  String get color => 'Color';

  @override
  String get selectColor => 'Select color';

  @override
  String get terminal => 'Terminal';

  @override
  String get termMaxLines => 'Max lines';

  @override
  String get unknown => 'Unknown';

  @override
  String get goBack => 'Go back';
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
  String get local => 'Local';

  @override
  String get localCreate => 'Create local terminal';

  @override
  String get localEdit => 'Edit local terminal';

  @override
  String get remote => 'Remote';

  @override
  String get remoteCreate => 'Create remote terminal';

  @override
  String get remoteEdit => 'Edit remote terminal';

  @override
  String get termName => 'Terminal name';

  @override
  String get termShell => 'Shell';

  @override
  String get termHost => 'Host';

  @override
  String get termPort => 'Port';

  @override
  String get termUser => 'User';

  @override
  String get termPass => 'Password';

  @override
  String inRequired(String name) {
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
  String get noTerm => 'No terminal';

  @override
  String get term => 'Terminal';

  @override
  String get setting => 'Setting';

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get useSystemAccent => 'Use system accent';

  @override
  String get color => 'Color';

  @override
  String get selectColor => 'Select color';

  @override
  String get terminal => 'Terminal';

  @override
  String get termMaxLines => 'Max lines';

  @override
  String get unknown => 'Unknown';

  @override
  String get goBack => 'Go back';
}
