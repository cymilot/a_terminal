// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore: unused_import
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
    String _temp1 = intl.Intl.selectLogic(
      type,
      {
        'local': 'local',
        'remote': 'remote',
        'other': '',
      },
    );
    String _temp2 = intl.Intl.pluralLogic(
      lower,
      locale: localeName,
      one: ' t',
      other: 'T',
    );
    return '$_temp0$_temp1${_temp2}erminal';
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
  String get emptyData => 'No data';

  @override
  String get emptyTerminal => 'No terminal';

  @override
  String get sftp => 'SFTP';

  @override
  String get history => 'History';

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
  String get dynamicColor => 'Dynamic color';

  @override
  String get switchColor => 'Select color';

  @override
  String get timeout => 'Time out';

  @override
  String get maxLines => 'Max lines';

  @override
  String get unknown => 'Unknown';

  @override
  String get back => 'Back';

  @override
  String get clear => 'Clear';

  @override
  String get drawer => 'Open drawer';

  @override
  String get edit => 'Edit';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get showPass => 'Show';

  @override
  String get hidePass => 'Hide';

  @override
  String get delete => ' Delete';

  @override
  String get refresh => 'Refresh';

  @override
  String get success => 'Success';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get cut => 'Cut';

  @override
  String get copy => 'Copy';

  @override
  String get paste => 'Paste';
}
