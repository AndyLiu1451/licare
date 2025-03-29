import 'package:flutter/material.dart'; // For TimeOfDay etc. (or remove if not needed directly)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For accessing database later if needed for payload
import 'package:timezone/data/latest_all.dart' as tz; // 时区数据
import 'package:timezone/timezone.dart' as tz; // 时区功能
import '../data/local/database/app_database.dart' show Reminder; // 引入 Reminder
import '../models/enum.dart'; // For ObjectType
import '../../../providers/database_provider.dart';

// Riverpod Provider for the service instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref); // Pass ref if needed later
});

class NotificationService {
  final Ref _ref; // Store ref if needed to access other providers
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    // 1. 初始化时区数据库
    tz.initializeTimeZones();
    // 可选: 设置本地时区 (如果应用需要特定时区逻辑)
    // tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // 2. Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // 使用你放在 drawable/mipmap 的图标名

    // 3. iOS 初始化设置
    final DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false, // 不在这里请求权限，在 AppDelegate 中请求
      requestBadgePermission: false,
      requestSoundPermission: false,
      //onDidReceiveLocalNotification: _onDidReceiveLocalNotification, // 旧版 iOS 回调
    );

    // 4. Linux 初始化设置 (如果未来支持桌面)
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');

    // 5. 整合各平台设置并初始化插件
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          // linux: initializationSettingsLinux,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 处理通知被点击的回调 (应用在前台、后台或终止状态)
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      // 处理旧版 iOS 应用在前台时收到通知的回调
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // (这个回调在文档中有时会混淆，优先用onDidReceiveNotificationResponse)
    );

    // 6. 请求 Android 13+ 通知权限
    await _requestAndroidPermissions();
    // 7. 请求 iOS 通知权限 (虽然在 AppDelegate 请求了，这里可以再检查一下状态)
    await _requestIOSPermissions();
  }

  // 请求 Android 权限
  Future<void> _requestAndroidPermissions() async {
    // 请求通知权限 (Android 13+)
    final bool? notificationPermissionGranted =
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission(); // 新版用 requestNotificationsPermission

    // 请求精确闹钟权限 (Android 12+) - 根据需要启用
    // final bool? exactAlarmPermissionGranted = await _flutterLocalNotificationsPlugin
    //    .resolvePlatformSpecificImplementation<
    //        AndroidFlutterLocalNotificationsPlugin>()
    //    ?.requestExactAlarmsPermission();

    print(
      'Android Notification Permission Granted: $notificationPermissionGranted',
    );
    // print('Android Exact Alarm Permission Granted: $exactAlarmPermissionGranted');
  }

  // 请求 iOS 权限 (确保或再次请求)
  Future<void> _requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // --- 回调处理 ---

  // 旧版 iOS 应用在前台收到通知的回调
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // 在这里可以显示一个对话框或做其他处理
    print(
      'iOS (foreground) received notification: id=$id, title=$title, payload=$payload',
    );
    // showDialog(...);
  }

  // 处理通知点击事件的回调
  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    final int? id = notificationResponse.id; // 通知 ID，可以对应 Reminder ID
    print(
      'Notification tapped: id=$id, payload=$payload, actionId=${notificationResponse.actionId}',
    );

    if (payload != null) {
      // TODO: 根据 payload 实现导航逻辑
      // 例如，payload 可以是 "reminder:123" 或 JSON 字符串 {"type": "reminder", "id": 123}
      // 解析 payload 并使用 GoRouter 导航到对应的详情页或编辑页
      if (payload.startsWith('reminder:')) {
        final reminderId = int.tryParse(payload.split(':')[1]);
        if (reminderId != null) {
          print('Navigating to reminder edit screen: $reminderId');
          // 需要 GoRouter 实例或一个全局导航 Key 来导航
          // globalNavigatorKey.currentState?.push(...);
          // 或者使用 deep linking / GoRouter 的 refresh 功能
        }
      }
    }
    // 可以在这里处理特定的 actionId (如果通知有按钮)
  }

  // --- 调度和取消通知 ---

  // 调度一个提醒通知
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!reminder.isActive || reminder.nextDueDate.isBefore(DateTime.now())) {
      print(
        'Reminder ${reminder.id} is inactive or overdue. Notification not scheduled.',
      );
      return; // 不为非激活或已过期的提醒调度通知
    }

    // 1. 定义 Android 通知详情
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'plant_pet_reminders_channel_id', // Channel ID
      'Plant & Pet Reminders', // Channel Name
      channelDescription: 'Notifications for plant and pet care reminders',
      importance: Importance.max, // 重要性 (影响通知显示方式)
      priority: Priority.high, // 优先级
      ticker: 'ticker', // 通知首次出现时的状态栏滚动文字
      playSound: true, // 播放声音
      // sound: RawResourceAndroidNotificationSound('notification_sound'), // 自定义声音 (需要放在 android/app/src/main/res/raw)
      // enableVibration: true,
      // styleInformation: DefaultStyleInformation(true, true), // 默认样式
      // TODO: 可以添加按钮 Action
    );

    // 2. 定义 iOS 通知详情
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      // sound: 'notification_sound.aiff', // 自定义声音
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // 3. 整合平台详情
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 4. 准备通知内容
    final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(
      reminder.nextDueDate, // 使用数据库中的下次执行时间
      tz.local, // 使用设备的本地时区
    );

    // 检查计划时间是否在过去 (避免立即触发) - 可能由于时区转换或延迟导致
    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print(
        'Scheduled time ${scheduledDateTime} is in the past for reminder ${reminder.id}. Skipping schedule.',
      );
      return;
    }

    // 5. 使用 zonedSchedule 调度通知
    // 通知 ID 使用 Reminder ID (必须是 32 位整数)
    final notificationId = reminder.id & 0x7FFFFFFF; // 确保 ID 在 32位整数范围内

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      reminder.taskName, // 通知标题 (任务名)
      _getNotificationBody(reminder), // 通知内容 (可以包含对象名)
      scheduledDateTime,
      platformDetails,
      // 定义通知的 Payload，用于点击通知时识别
      payload: 'reminder:${reminder.id}', // 简单 payload
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 允许在低功耗模式下精确调度
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // iOS 时间解释方式
      // matchDateTimeComponents: DateTimeComponents.time, // 如果是每天重复的通知，可以匹配时间部分
    );

    print(
      'Scheduled notification for reminder ${reminder.id} at $scheduledDateTime (ID: $notificationId)',
    );

    // TODO: 处理重复提醒的调度逻辑
    // 对于重复提醒，当通知触发后 (或用户标记完成后)，需要根据 frequencyRule 计算下一次时间，
    // 并再次调用 zonedSchedule 来安排下一次通知。这通常在通知回调或标记完成的逻辑中处理。
    // flutter_local_notifications 本身对复杂重复规则的支持有限，可能需要自己管理。
  }

  // (Helper) 获取通知内容，尝试包含对象名
  String _getNotificationBody(Reminder reminder) {
    // 这里可以尝试同步或异步获取对象名称，但为了简化，先不加
    // final objectName = await _ref.read(_objectNameProvider(...));
    if (reminder.notes != null && reminder.notes!.isNotEmpty) {
      return reminder.notes!; // 如果有备注，优先显示备注
    }
    // return '该为 [对象名称] 做 ${reminder.taskName} 了'; // 包含对象名的示例
    return '是时候完成任务 "${reminder.taskName}" 了！'; // 默认内容
  }

  // 取消一个通知
  Future<void> cancelNotification(int reminderId) async {
    final notificationId = reminderId & 0x7FFFFFFF;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print(
      'Cancelled notification for reminder $reminderId (ID: $notificationId)',
    );
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all notifications');
  }

  // (可选) 应用启动时重新调度所有激活的提醒 (以防错过或应用更新导致丢失)
  Future<void> rescheduleAllActiveReminders() async {
    print('Rescheduling all active reminders...');
    await cancelAllNotifications(); // 先取消所有旧的

    final db = _ref.read(databaseProvider); // 需要 Ref 来访问数据库
    final activeReminders =
        await (db.select(db.reminders)
          ..where((tbl) => tbl.isActive.equals(true))).get();

    int scheduledCount = 0;
    for (final reminder in activeReminders) {
      try {
        await scheduleReminderNotification(reminder);
        scheduledCount++;
      } catch (e) {
        print('Error rescheduling reminder ${reminder.id}: $e');
      }
    }
    print('Rescheduled $scheduledCount active reminders.');
  }
}
