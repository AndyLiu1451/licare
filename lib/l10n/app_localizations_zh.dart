// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '植宠日志';

  @override
  String get plants => '植物';

  @override
  String get pets => '宠物';

  @override
  String get reminders => '提醒';

  @override
  String get settings => '设置';

  @override
  String get knowledgeBase => '知识库';

  @override
  String get myPlants => '我的植物';

  @override
  String get myPets => '我的宠物';

  @override
  String get upcomingReminders => '待办提醒';

  @override
  String get settingsAndData => '设置与数据';

  @override
  String get addPlant => '添加植物';

  @override
  String get addPet => '添加宠物';

  @override
  String get addReminder => '添加提醒';

  @override
  String get addLogEntry => '添加日志记录';

  @override
  String get addNewEventType => '添加新类型...';

  @override
  String get name => '名称';

  @override
  String get nickname => '昵称';

  @override
  String get optional => '(可选)';

  @override
  String get species => '品种/学名';

  @override
  String get breed => '具体品种';

  @override
  String get acquisitionDate => '获取日期';

  @override
  String get birthDate => '生日';

  @override
  String get room => '放置位置';

  @override
  String get gender => '性别';

  @override
  String get male => '雄性';

  @override
  String get female => '雌性';

  @override
  String get unknown => '未知';

  @override
  String get selectDate => '(选择日期)';

  @override
  String get selectTime => '(选择时间)';

  @override
  String get eventType => '事件类型';

  @override
  String get selectEventType => '选择事件类型 *';

  @override
  String get customEventTypeHint => '输入自定义事件类型 *';

  @override
  String get eventTime => '事件时间 *';

  @override
  String get notes => '备注';

  @override
  String get addPhotos => '添加照片 (可选, 最多5张)';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get confirmDeleteTitle => '确认删除?';

  @override
  String confirmDeleteContent(String itemName) {
    return '确定要删除 “$itemName” 吗？此操作无法撤销。';
  }

  @override
  String get deletePlantConfirmation => '确定要删除这棵植物吗？相关的日志和提醒也会一并删除。此操作无法撤销。';

  @override
  String get deletePetConfirmation => '确定要删除这只宠物吗？相关的日志和提醒也会一并删除。此操作无法撤销。';

  @override
  String deleteReminderConfirmation(String taskName) {
    return '确定要删除任务 “$taskName” 吗？此操作无法撤销。';
  }

  @override
  String deleteLogConfirmation(String eventType) {
    return '确定要删除这条关于 “$eventType” 的日志记录吗？此操作无法撤销。';
  }

  @override
  String deleteEventTypeConfirmation(String typeName) {
    return '确定要删除事件类型 “$typeName” 吗？此操作无法撤销。';
  }

  @override
  String get noPlants => '还没有添加植物哦，\n点击右下角按钮添加一个吧！';

  @override
  String get noPets => '还没有添加宠物哦，\n点击右下角按钮添加一个吧！';

  @override
  String get noReminders => '没有待办提醒。';

  @override
  String get noActiveReminders => '没有激活的提醒。';

  @override
  String get noOverdueReminders => '没有已过期的提醒。';

  @override
  String get noInactiveReminders => '没有已暂停的提醒。';

  @override
  String get noRemindersFound => '没有找到符合条件的提醒。';

  @override
  String get noLogs => '还没有日志记录。';

  @override
  String get noPhotos => '还没有任何照片记录。';

  @override
  String get noKnowledge => '暂无知识内容。';

  @override
  String loadingFailed(String error) {
    return '加载失败: $error';
  }

  @override
  String get errorNotFound => '项目未找到。';

  @override
  String get errorInvalidData => '无效数据。';

  @override
  String errorSavingFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String errorDeletingFailed(String error) {
    return '删除失败: $error';
  }

  @override
  String get errorBackupFailed => '备份失败。';

  @override
  String get errorRestoreFailed => '恢复失败或已取消。';

  @override
  String errorExportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String errorNameExists(String name) {
    return '错误：名称 “$name” 已存在。';
  }

  @override
  String get plantDetails => '植物详情';

  @override
  String get petDetails => '宠物详情';

  @override
  String get editPlant => '编辑植物';

  @override
  String get editPet => '编辑宠物';

  @override
  String get editReminder => '编辑提醒';

  @override
  String get editEventType => '编辑事件类型';

  @override
  String get addEventType => '添加新事件类型';

  @override
  String get appearance => '外观';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色模式';

  @override
  String get darkTheme => '深色模式';

  @override
  String get themeColor => '主题颜色';

  @override
  String get dataManagement => '数据管理';

  @override
  String get backupData => '备份数据';

  @override
  String get backupDataDesc => '将当前数据备份到选定位置';

  @override
  String get restoreData => '恢复数据';

  @override
  String get restoreDataDesc => '从备份文件恢复（覆盖当前数据！）';

  @override
  String get exportLogs => '导出日志为 CSV';

  @override
  String get exportLogsDesc => '将日志记录导出为表格文件';

  @override
  String get learningHelp => '学习与帮助';

  @override
  String get manageEventTypes => '管理日志事件类型';

  @override
  String get manageEventTypesDesc => '添加、编辑或删除自定义类型';

  @override
  String get backupInProgress => '正在备份...';

  @override
  String get backupSuccess => '备份成功！已保存到选定目录。';

  @override
  String get backupCancelled => '备份已取消。';

  @override
  String get restoreConfirmTitle => '确认恢复数据?';

  @override
  String get restoreConfirmDesc => '将使用选定的备份文件覆盖当前所有数据！\n\n**强烈建议您先执行一次备份。**\n\n恢复成功后，应用将需要重启才能加载新数据。\n\n确定要继续吗？';

  @override
  String get restoreContinue => '继续恢复';

  @override
  String get restoreCancelled => '恢复已取消。';

  @override
  String get selectBackupFile => '请选择备份文件...';

  @override
  String get restoreSuccess => '恢复成功！请手动重启应用以加载新数据。';

  @override
  String get exportingLogs => '正在导出日志数据...';

  @override
  String get noLogsToExport => '没有日志数据可导出。';

  @override
  String get sort => '排序';

  @override
  String get filter => '筛选';

  @override
  String get sortNameAsc => '名称 A-Z';

  @override
  String get sortNameDesc => '名称 Z-A';

  @override
  String get sortDateAddedAsc => '添加日期 (最早)';

  @override
  String get sortDateAddedDesc => '添加日期 (最近)';

  @override
  String get sortDueDateAsc => '截止日期 (最早)';

  @override
  String get sortDueDateDesc => '截止日期 (最近)';

  @override
  String get sortBirthDateAsc => '生日 (最早)';

  @override
  String get sortBirthDateDesc => '生日 (最近)';

  @override
  String get filterAll => '显示全部';

  @override
  String get filterActiveOnly => '仅激活';

  @override
  String get filterInactiveOnly => '仅暂停';

  @override
  String get filterOverdueOnly => '仅过期';

  @override
  String get language => '语言';

  @override
  String get photoGallery => '照片墙';

  @override
  String get viewPhotoGallery => '查看照片墙';

  @override
  String selectPhotos(int count) {
    return '选择照片 ($count/2)';
  }

  @override
  String get compare => '对比';

  @override
  String get cancelSelection => '取消选择';

  @override
  String get maxPhotosSelected => '最多只能选择两张照片进行对比';

  @override
  String get growthComparison => '成长对比';

  @override
  String get viewFullScreen => '查看大图 (待实现)';

  @override
  String get errorLoadingImage => '无法加载图片';

  @override
  String get knowledgeBaseDesc => '查看常见植物和宠物知识';

  @override
  String get search => '查找';

  @override
  String get markDone => '标记完成';

  @override
  String get toggleActiveOn => '激活提醒';

  @override
  String get toggleActiveOff => '暂停提醒';

  @override
  String reminderCompleted(String taskName) {
    return '任务 “$taskName” 已完成！';
  }

  @override
  String reminderCompletedNext(String taskName) {
    return '任务 “$taskName” 已完成！下次时间已更新。';
  }

  @override
  String markDoneFailed(String error) {
    return '标记完成失败: $error';
  }

  @override
  String get selectIcon => '选择图标';

  @override
  String get typeName => '类型名称 *';

  @override
  String get cannotDeletePreset => '无法删除预设类型。';

  @override
  String get confirmDeleteEventTypeTitle => '确认删除?';

  @override
  String get plantKnowledge => '植物知识';

  @override
  String get petKnowledge => '宠物知识';

  @override
  String get topicNotFound => '未找到主题内容。';

  @override
  String loadingKnowledgeFailed(String error) {
    return '加载知识失败: $error';
  }

  @override
  String get watering => '浇水';

  @override
  String get fertilizing => '施肥';

  @override
  String get repotting => '换盆';

  @override
  String get pruning => '修剪';

  @override
  String get lightChange => '光照变化';

  @override
  String get pestControl => '病虫害';

  @override
  String get feeding => '喂食';

  @override
  String get medication => '用药';

  @override
  String get vaccination => '疫苗';

  @override
  String get dewormingInternal => '体内驱虫';

  @override
  String get dewormingExternal => '体外驱虫';

  @override
  String get grooming => '洗澡/美容';

  @override
  String get weightRecord => '体重记录';

  @override
  String get behaviorObservation => '行为观察';

  @override
  String get vetVisit => '就诊';

  @override
  String get other => '其他';
}
