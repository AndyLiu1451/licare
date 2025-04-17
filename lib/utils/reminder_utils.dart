// lib/utils/reminder_utils.dart

import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart'; // 确保已导入 rrule 包
import 'package:timezone/timezone.dart' as tz;
import '../data/local/database/app_database.dart' show Reminder; // 确保路径正确

// RruleL10n* 的 import 不再需要

class ReminderUtils {
  /// Calculates the next occurrence time for a reminder AFTER a given date.
  /// Returns null if the reminder is 'ONCE' or calculation fails.
  static tz.TZDateTime? calculateNextDueDate(
    Reminder reminder, {
    required tz.Location location,
  }) {
    if (reminder.frequencyRule == null ||
        reminder.frequencyRule!.isEmpty ||
        reminder.frequencyRule == 'ONCE') {
      return null; // Not a recurring reminder
    }

    try {
      // Convert the current due date to the correct timezone for calculation
      final tz.TZDateTime currentDueTz = tz.TZDateTime.from(
        reminder.nextDueDate,
        location,
      );

      // Parse the RRULE string.
      final rrule = RecurrenceRule.fromString(reminder.frequencyRule!);

      // Find the first occurrence strictly AFTER the current due date.
      final nextInstance =
          rrule
              .getAllInstances(
                start:
                    currentDueTz, // Provide context for where the rule 'starts' evaluating *from*
                after:
                    currentDueTz, // Find instances strictly *after* this time
                includeAfter: false, // Ensure it's strictly after
              )
              .firstOrNull; // Get the first result, or null if none exist

      if (nextInstance != null) {
        // Ensure the result is in the correct timezone
        if (nextInstance is tz.TZDateTime) {
          return nextInstance;
        } else {
          // If rrule returns local DateTime, convert it using the location
          return tz.TZDateTime.from(nextInstance, location);
        }
      } else {
        print(
          "rrule could not find next instance for rule: ${reminder.frequencyRule} after $currentDueTz",
        );
        return null; // No further occurrences found
      }
    } catch (e) {
      print(
        "Error calculating next due date for rule '${reminder.frequencyRule}': $e",
      );
      return null; // Calculation failed
    }
  }

  /// Formats the RRULE string into a user-friendly Chinese description.
  static String formatFrequencyRuleForDisplay(String? ruleString) {
    if (ruleString == null || ruleString.isEmpty || ruleString == 'ONCE')
      return '仅一次';
    try {
      final rrule = RecurrenceRule.fromString(ruleString);
      final freq = rrule.frequency;
      final int interval = rrule.interval ?? 1;
      // **假设 byWeekDays 列表中的 entry.day 是 int (1-7)**
      final byWeekDays = rrule.byWeekDays;
      final byMonthDays = rrule.byMonthDays;

      String freqText = "";
      switch (freq) {
        case Frequency.daily:
          freqText = "天";
          break;
        case Frequency.weekly:
          freqText = "周";
          break;
        case Frequency.monthly:
          freqText = "月";
          break;
        case Frequency.yearly:
          freqText = "年";
          break;
        default:
          return ruleString;
      }

      String intervalText = interval > 1 ? "每 $interval " : "每";
      String detailsText = "";

      if (freq == Frequency.weekly && byWeekDays.isNotEmpty) {
        const List<String> days = ['一', '二', '三', '四', '五', '六', '日']; // 索引 0-6
        List<String> selectedDays = [];

        // **修改点 1: 对整数列表排序**
        // entry.day 被假定为 int (1-7)
        List<int> sortedWeekDaysInts =
            byWeekDays.map((entry) => entry.day).toList();
        sortedWeekDaysInts.sort(); // 直接对整数排序 (1 到 7)

        for (int dayInt in sortedWeekDaysInts) {
          // **修改点 2: 将整数 (1-7) 转换为数组索引 (0-6)**
          int dayIndex = dayInt - 1;
          if (dayIndex >= 0 && dayIndex < days.length) {
            selectedDays.add(days[dayIndex]);
          }
        }
        if (selectedDays.isNotEmpty) {
          detailsText = " 周${selectedDays.join('、')}";
        }
      } else if (freq == Frequency.monthly && byMonthDays.isNotEmpty) {
        List<int> sortedMonthDays = List.from(byMonthDays);
        sortedMonthDays.sort();
        detailsText = " ${sortedMonthDays.join(',')} 号";
      }

      if (interval == 1) {
        if (freq == Frequency.daily) return "每天";
        return "每$freqText$detailsText";
      } else {
        return "$intervalText$freqText$detailsText";
      }
    } catch (e) {
      print("Error parsing RRULE '$ruleString' for display: $e");
      return ruleString ?? '无效规则'; // 使用原始字符串作为回退
    }
  }
}
