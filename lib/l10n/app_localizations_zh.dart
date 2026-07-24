// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get applicationTitle => 'Floatick';

  @override
  String get openApp => '打开 Floatick';

  @override
  String get openAppHint => '拖动可移动位置，点击展开待办列表';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearanceSectionTitle => '外观';

  @override
  String get languageSectionTitle => '语言';

  @override
  String get languageSystemTooltip => '跟随系统';

  @override
  String get languageSimplifiedChineseTooltip => '简体中文';

  @override
  String get languageEnglishTooltip => 'English';

  @override
  String get updatesSectionTitle => '更新';

  @override
  String currentVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get automaticUpdateChecksLabel => '自动检查更新';

  @override
  String get automaticUpdateChecksDescription => '每天检查一次，安装前会询问你';

  @override
  String get checkForUpdatesButton => '检查更新';

  @override
  String get checkingForUpdatesButton => '正在检查…';

  @override
  String get updateSettingsLoadError => '暂时无法读取更新设置。';

  @override
  String get updateSettingsSaveError => '无法修改更新设置。';

  @override
  String get updateCheckError => '暂时无法检查更新。';

  @override
  String get workingDirectorySectionTitle => '工作目录';

  @override
  String workingDirectorySemantics(String path) {
    return '工作目录：$path';
  }

  @override
  String get closeSettingsTooltip => '关闭设置';

  @override
  String get themeSystemTooltip => '跟随系统';

  @override
  String get themeLightTooltip => '浅色主题';

  @override
  String get themeDarkTooltip => '深色主题';

  @override
  String get searchTodosHint => '搜索待办';

  @override
  String get searchArchiveHint => '搜索归档';

  @override
  String get clearSearchTooltip => '清除搜索';

  @override
  String get addTodoHint => '添加一件要完成的事…';

  @override
  String get allClearToday => '今天已经清空';

  @override
  String activeTodoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项待完成',
    );
    return '$_temp0';
  }

  @override
  String get settingsTooltip => '设置';

  @override
  String get collapseTooltip => '收起（Esc）';

  @override
  String get activeScopeLabel => '待办';

  @override
  String get archiveScopeLabel => '归档';

  @override
  String get addTodoSemanticsLabel => '添加待办';

  @override
  String get addTodoTooltip => '添加待办（Return）';

  @override
  String get dismissErrorTooltip => '关闭错误提示';

  @override
  String get completedStatus => '已完成';

  @override
  String get incompleteStatus => '未完成';

  @override
  String get markIncompleteTooltip => '标记为未完成';

  @override
  String get markCompleteTooltip => '标记为已完成';

  @override
  String get todoTitleRequiredHint => '待办内容不能为空';

  @override
  String get saveTooltip => '保存';

  @override
  String get editTooltip => '编辑';

  @override
  String get cancelEditTooltip => '取消编辑';

  @override
  String get restoreTooltip => '恢复到待办';

  @override
  String get archiveTooltip => '归档';

  @override
  String get noSearchResultsTitle => '没有匹配的结果';

  @override
  String get emptyArchiveTitle => '归档还是空的';

  @override
  String get emptyTodosTitle => '没有待办，享受此刻';

  @override
  String get noSearchResultsMessage => '换一个关键词试试';

  @override
  String get emptyArchiveMessage => '归档的事项会保存在这里';

  @override
  String get emptyTodosMessage => '在上方随时添加新事项';

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String get storageInvalidDataError => '本地数据文件已损坏，文件保持不变。';

  @override
  String storageReadError(String path) {
    return 'Floatick 无法读取 $path。';
  }

  @override
  String storageWriteError(String path) {
    return 'Floatick 无法保存到 $path。';
  }

  @override
  String get storageHomeError => 'Floatick 无法获取当前 macOS 用户目录。';
}
