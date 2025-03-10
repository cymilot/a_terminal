// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppL10nZh extends AppL10n {
  AppL10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ATerminal';

  @override
  String get exitTip => '再点击一次退出';

  @override
  String get addNew => '添加新的终端';

  @override
  String terminal(String action, String type, int lower) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'create': '创建',
        'edit': '编辑',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      type,
      {
        'local': '本地',
        'remote': '远程',
        'other': '',
      },
    );
    String _temp2 = intl.Intl.pluralLogic(
      lower,
      locale: localeName,
      one: '',
      other: '',
    );
    return '$_temp0$_temp1$_temp2终端';
  }

  @override
  String get terminalName => '名称';

  @override
  String get terminalShell => 'Shell';

  @override
  String get terminalHost => '主机地址';

  @override
  String get terminalPort => '端口';

  @override
  String get terminalUser => '用户名';

  @override
  String get terminalPass => '密码';

  @override
  String get local => '本地';

  @override
  String get remote => '远程';

  @override
  String isRequired(String name) {
    return '$name是必填项';
  }

  @override
  String inSelecting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      one: '1',
      zero: '0',
    );
    return '选择了$_temp0个';
  }

  @override
  String get home => '主页';

  @override
  String get emptyData => '没有数据';

  @override
  String get emptyTerminal => '没有终端';

  @override
  String get sftp => 'SFTP';

  @override
  String get history => '历史';

  @override
  String get settings => '设置';

  @override
  String get general => '一般';

  @override
  String get theme => '主题';

  @override
  String get systemTheme => '系统默认';

  @override
  String get lightTheme => '明亮主题';

  @override
  String get darkTheme => '暗黑主题';

  @override
  String get color => '主题色';

  @override
  String get dynamicColor => '系统强调色';

  @override
  String get switchColor => '选择主题色';

  @override
  String get timeout => '超时时间';

  @override
  String get maxLines => '最大行数';

  @override
  String get unknown => '未知';

  @override
  String get back => '返回';

  @override
  String get clear => '清除';

  @override
  String get drawer => '打开抽屉';

  @override
  String get edit => '编辑';

  @override
  String get submit => '提交';

  @override
  String get cancel => '取消';

  @override
  String get showPass => '显示密码';

  @override
  String get hidePass => '隐藏密码';

  @override
  String get delete => ' 删除';

  @override
  String get refresh => '刷新';

  @override
  String get success => '成功';

  @override
  String get save => '保存';

  @override
  String get close => '关闭';

  @override
  String get cut => '剪切';

  @override
  String get copy => '复制';

  @override
  String get paste => '粘贴';
}
