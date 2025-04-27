import 'package:flutter/material.dart'; // For TimeOfDay etc. (or remove if not needed directly)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For accessing database later if needed for payload
import 'package:timezone/data/latest_all.dart'
    as tz_data; // Renamed to avoid conflict
import 'package:timezone/timezone.dart' as tz; // 时区功能
import '../data/local/database/app_database.dart' show Reminder; // 引入 Reminder
import '../models/enum.dart'; // For ObjectType
import '../providers/database_provider.dart'; // Corrected import path assumption

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
      sound: RawResourceAndroidNotificationSound(
        'notification_sound',
      ), // Optional custom sound
      enableVibration: true,
      styleInformation: DefaultStyleInformation(true, true), // Optional style
    );

    // 2. Define iOS Notification Details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'notification_sound.aiff', // Optional custom sound
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
    // 1. Initialize timezone database (needs to happen before using tz.local)
    tz_data.initializeTimeZones();
    // 2. !! REMOVED: tz.setLocalLocation(tz.getLocation('UTC')); !!
    //    Let the timezone package detect the actual local timezone.

    // 3. Android Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'app_icon',
        ); // Use your drawable/mipmap icon name

    // 4. iOS Initialization Settings
    final DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission:
          false, // Permissions requested elsewhere (AppDelegate)
      requestBadgePermission: false,
      requestSoundPermission: false,
      //onDidReceiveLocalNotification: _onDidReceiveLocalNotification, // Old iOS callback
    );

    // 5. Consolidate settings and initialize plugin
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          // linux: initializationSettingsLinux, // If supporting Linux
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Callback for notification tap (foreground, background, terminated)
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      // Callback for old iOS foreground notifications
      // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // 6. Request Android permissions (Android 13+)
    await _requestAndroidPermissions();
    // 7. Request iOS permissions (can re-check status here)
    await _requestIOSPermissions();
  }

  // Request Android Permissions
  Future<void> _requestAndroidPermissions() async {
    final plugin =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (plugin != null) {
      final bool? granted = await plugin.requestNotificationsPermission();
      print('Android Notification Permission Granted: $granted');
      // Optionally request exact alarm permission if needed
      // final bool? exactAlarmGranted = await plugin.requestExactAlarmsPermission();
      // print('Android Exact Alarm Permission Granted: $exactAlarmGranted');
    }
  }

  // Request iOS Permissions (placeholder, usually done in AppDelegate)
  Future<void> _requestIOSPermissions() async {
    // If needed, can use plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>().requestPermissions(...)
    print("iOS permission request handled in AppDelegate or manually.");
  }

  // --- Callbacks ---

  // Old iOS foreground notification callback
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    print(
      'iOS (foreground) received notification: id=$id, title=$title, payload=$payload',
    );
    // Display a dialog or handle as needed
  }

  // Notification tap callback
  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    final int? id =
        notificationResponse.id; // Notification ID (maps to Reminder ID)
    print(
      'Notification tapped: id=$id, payload=$payload, actionId=${notificationResponse.actionId}',
    );

    if (payload != null && payload.startsWith('reminder:')) {
      final reminderId = int.tryParse(payload.split(':')[1]);
      if (reminderId != null) {
        print('Navigation payload detected for reminder: $reminderId');
        // TODO: Implement navigation logic using GoRouter or Navigator
        // Example: _ref.read(goRouterProvider).go('/edit-reminder/$reminderId');
      }
    }
  }

  // --- Scheduling and Cancelling ---

  // Schedule a reminder notification
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    // 1. Ensure timezones are initialized (redundant if initialize() called, but safe)
    try {
      tz_data.initializeTimeZones();
    } catch (_) {
      // Already initialized likely
    }
    // 2. !! Get the ACTUAL local timezone !!
    late final tz.Location location;
    try {
      location = tz.local;
    } catch (e) {
      print(
        "Error getting local timezone: $e. Defaulting to UTC for scheduling.",
      );
      // Fallback or rethrow, depending on desired behavior
      location = tz.getLocation('UTC');
    }

    // 3. !! CRITICAL: Construct TZDateTime using LOCAL timezone and DB DateTime components !!
    //    Assume reminder.nextDueDate stores the intended *local* date and time.
    late final tz.TZDateTime scheduledDateTime;
    try {
      final DateTime dbDateTime = reminder.nextDueDate;
      // Create TZDateTime explicitly using the components and the local location
      scheduledDateTime = tz.TZDateTime(
        location, // Use the determined local location
        dbDateTime.year,
        dbDateTime.month,
        dbDateTime.day,
        dbDateTime.hour,
        dbDateTime.minute,
        dbDateTime.second,
      );

      print(
        "DB DateTime components: Year=${dbDateTime.year}, Month=${dbDateTime.month}, Day=${dbDateTime.day}, Hour=${dbDateTime.hour}, Min=${dbDateTime.minute}",
      );
      print(
        "Constructed schedule time: ${scheduledDateTime.toIso8601String()} in Location: ${location.name}",
      );
    } catch (e) {
      print(
        "Error constructing local TZDateTime from reminder.nextDueDate: $e. Cannot schedule.",
      );
      return; // Stop if construction fails
    }

    // 4. Check if reminder is active and if the calculated schedule time is in the past
    final nowLocalTz = tz.TZDateTime.now(location);
    if (!reminder.isActive) {
      print('Reminder ${reminder.id} is inactive. Notification not scheduled.');
      return;
    }
    // Add a small buffer (e.g., 1 second) to prevent race conditions
    if (scheduledDateTime.isBefore(
      nowLocalTz.add(const Duration(seconds: 1)),
    )) {
      print(
        'Reminder ${reminder.id} schedule time ${scheduledDateTime.toIso8601String()} is in the past compared to now ${nowLocalTz.toIso8601String()}. Notification not scheduled.',
      );
      // Optionally: Calculate the *next* occurrence based on frequency rule here
      // if (reminder.frequency != null) { ... recalculate and reschedule ... }
      return;
    }

    // 5. Define Android Notification Details (Consistent)
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'plant_pet_reminders_channel_id', // Channel ID
          'Plant & Pet Reminders', // Channel Name
          channelDescription: '用于植物和宠物护理提醒的通知', // Channel Description
          importance: Importance.max,
          priority: Priority.high,
          ticker: '任务提醒',
          playSound: true,
        );

    // 6. Define iOS Notification Details (Consistent)
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // 7. Consolidate Platform Details (Consistent)
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 8. Schedule the notification using zonedSchedule
    // Use reminder.id directly or masked if > 31 bits needed for Android ID
    final notificationId =
        reminder.id & 0x7FFFFFFF; // Ensure 32-bit int for notification ID
    print(
      'Scheduling notification for reminder ${reminder.id} at $scheduledDateTime in timezone ${location.name} (Notification ID: $notificationId)',
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        reminder.taskName, // Title
        _getNotificationBody(reminder), // Body
        scheduledDateTime, // !! Pass the correctly constructed local TZDateTime !!
        platformDetails,
        payload: 'reminder:${reminder.id}', // Payload for navigation
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // Use exact timing
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation
                .absoluteTime, // Use absolute time
      );
      print('Notification for reminder ${reminder.id} successfully scheduled.');
    } catch (e) {
      print('Error scheduling notification for reminder ${reminder.id}: $e');
      // Consider how to handle scheduling errors (e.g., retry, log to analytics)
    }
  }

  // Helper to get notification body
  String _getNotificationBody(Reminder reminder) {
    if (reminder.notes != null && reminder.notes!.isNotEmpty) {
      return reminder.notes!;
    }
    // Consider fetching Plant/Pet name if objectId/Type are available
    return '是时候完成任务 "${reminder.taskName}" 了！';
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int reminderId) async {
    final notificationId = reminderId & 0x7FFFFFFF;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print(
      'Cancelled notification for reminder $reminderId (ID: $notificationId)',
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all notifications');
  }

  // Reschedule all active reminders on app start (optional but recommended)
  Future<void> rescheduleAllActiveReminders() async {
    print('Rescheduling all active reminders...');
    await cancelAllNotifications(); // Cancel existing ones first

    final db = _ref.read(databaseProvider);
    final activeReminders =
        await (db.select(db.reminders)
          ..where((tbl) => tbl.isActive.equals(true))).get();

    int scheduledCount = 0;
    int skippedCount = 0;
    for (final reminder in activeReminders) {
      try {
        // Call scheduleReminderNotification which now contains the past check
        await scheduleReminderNotification(reminder);
        // Check if it was actually scheduled (not skipped for being in the past)
        final pending =
            await _flutterLocalNotificationsPlugin
                .pendingNotificationRequests();
        if (pending.any((req) => req.id == (reminder.id & 0x7FFFFFFF))) {
          scheduledCount++;
        } else {
          // It might have been skipped if overdue during reschedule
          print(
            "Reminder ${reminder.id} likely skipped during reschedule (already past due).",
          );
          skippedCount++;
        }
      } catch (e) {
        print('Error rescheduling reminder ${reminder.id}: $e');
      }
    }
    print(
      'Reschedule finished: $scheduledCount reminders scheduled, $skippedCount skipped (likely past due).',
    );
  }
}
