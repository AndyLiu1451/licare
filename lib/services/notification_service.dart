import 'package:flutter/material.dart'; // For TimeOfDay etc. (or remove if not needed directly)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For accessing database later if needed for payload
import 'package:timezone/data/latest_all.dart' as tz; // 时区数据
import 'package:timezone/data/latest_all.dart' as tz_data;
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

  Future<void> showNowNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print("Attempting to show notification now: ID=$id, Title='$title'");

    // 1. Define Android Notification Details (use the same channel as scheduled ones)
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'plant_pet_reminders_channel_id', // Use the same Channel ID
      'Plant & Pet Reminders', // Use the same Channel Name
      channelDescription:
          'Notifications for plant and pet care reminders', // Same description
      importance: Importance.max, // High importance to ensure visibility
      priority: Priority.high,
      ticker: 'ticker', // Optional ticker text
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification_sound'), // Optional custom sound
      // enableVibration: true,
      // styleInformation: DefaultStyleInformation(true, true), // Optional style
    );

    // 2. Define iOS Notification Details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      // sound: 'notification_sound.aiff', // Optional custom sound
      presentAlert: true, // Ensure alert is shown
      presentBadge:
          true, // Optional: Update badge count (usually requires more logic)
      presentSound: true, // Ensure sound is played
    );

    // 3. Combine platform details
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 4. Show the notification using flutterLocalNotificationsPlugin.show()
    try {
      await _flutterLocalNotificationsPlugin.show(
        id, // Notification ID
        title, // Notification Title
        body, // Notification Body
        platformDetails, // Platform specific details
        payload: payload, // Optional payload
      );
      print(
        "Notification successfully shown (ID: $id). Check the device/simulator.",
      );
    } catch (e) {
      print("Error showing notification (ID: $id): $e");
      // Handle error appropriately, maybe show a snackbar
    }
  }

  Future<void> initialize() async {
    // 1. 初始化时区数据库
    tz.initializeTimeZones();
    // 2. Set the local location (use a general identifier like 'UTC' or 'Etc/GMT')
    tz.setLocalLocation(tz.getLocation('UTC')); // Or 'Etc/GMT'
    
    
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
  Future<void> _requestIOSPermissions() async {}

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
    // 1. Ensure timezones are initialized
    try {
      tz_data.initializeTimeZones();
    } catch (_) {}
    final location = tz.local; // Get the local timezone location object
    final nowLocalTz = tz.TZDateTime.now(location);

    // 2. !! CRITICAL: Convert DB DateTime (assumed UTC) to Local TZDateTime !!
    //    This is the definitive conversion point.
    late final tz.TZDateTime scheduledDateTime; // Use late final

    try {
      // Assume reminder.nextDueDate from DB is DateTime, likely representing UTC epoch seconds
      final DateTime nextDueUtcFromDb = reminder.nextDueDate;
      scheduledDateTime = tz.TZDateTime.from(nextDueUtcFromDb, location);
      print(
        "Converted DB DateTime ${nextDueUtcFromDb.toIso8601String()} (isUtc: ${nextDueUtcFromDb.isUtc}) to Local TZDateTime ${scheduledDateTime.toIso8601String()} (Location: ${scheduledDateTime.location.name})",
      );
    } catch (e) {
      print(
        "Error converting reminder.nextDueDate to local TZDateTime: $e. Cannot schedule.",
      );
      return; // Stop if conversion fails
    }

    // 3. Check if reminder is active and not already overdue using the converted local time
    if (!reminder.isActive || scheduledDateTime.isBefore(nowLocalTz)) {
      print(
        'Reminder ${reminder.id} is inactive or overdue (Scheduled Local: $scheduledDateTime vs Now Local: $nowLocalTz). Notification not scheduled.',
      );
      return;
    }

    // 4. Define Android Notification Details (Keep as before)
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'plant_pet_reminders_channel_id', // Channel ID (Keep this consistent)
      'Plant & Pet Reminders', // Channel Name (User visible in settings)
      channelDescription:
          '用于植物和宠物护理提醒的通知', // Channel Description (User visible in settings)
      importance: Importance.max, // High importance for reminders
      priority: Priority.high,
      ticker: '任务提醒', // Optional ticker text
      playSound: true,
      // sound: ..., // Optional custom sound
      // enableVibration: true, // Optional vibration
      // visibility: NotificationVisibility.public, // Optional lock screen visibility
      // other properties...
    );

    // 5. Define iOS Notification Details (Keep as before)
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // threadIdentifier: 'reminder_thread', // Optional: Group notifications
    );

    // 6. Consolidate Platform Details (Keep as before)
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 7. Final check if time is in the past (using the converted local time)
    if (scheduledDateTime.isBefore(tz.TZDateTime.now(location))) {
      print(
        'Scheduled time ${scheduledDateTime} (in ${location.name}) is in the past just before scheduling reminder ${reminder.id}. Skipping.',
      );
      return;
    }

    // 8. Schedule the notification using zonedSchedule
    final notificationId = reminder.id & 0x7FFFFFFF;
    print(
      'Scheduling notification for reminder ${reminder.id} at $scheduledDateTime in timezone ${scheduledDateTime.location.name} (ID: $notificationId)',
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        reminder.taskName,
        _getNotificationBody(reminder),
        scheduledDateTime, // !! Pass the verified local TZDateTime !!
        platformDetails,
        payload: 'reminder:${reminder.id}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification for reminder ${reminder.id} successfully scheduled.');
    } catch (e) {
      print('Error scheduling notification for reminder ${reminder.id}: $e');
    }
  }

  // Helper to get notification body (Keep as before)
  String _getNotificationBody(Reminder reminder) {
    if (reminder.notes != null && reminder.notes!.isNotEmpty) {
      return reminder.notes!;
    }
    return '是时候完成任务 "${reminder.taskName}" 了！';
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
