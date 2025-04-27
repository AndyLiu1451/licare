// lib/utils/reminder_utils.dart

import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart'; // 确保已导入 rrule 包
import 'package:timezone/timezone.dart' as tz;
import '../data/local/database/app_database.dart' show Reminder; // 确保路径正确
import 'package:collection/collection.dart'; // 引入 collection 包以使用 firstWhereOrNull (如果需要)

class ReminderUtils {
  static tz.TZDateTime? calculateNextDueDate(
    Reminder reminder, {
    required tz.Location location,
  }) {
    final String? ruleString = reminder.frequencyRule;
    print("==> START calculateNextDueDate - Rule: $ruleString");

    if (ruleString == null || ruleString.isEmpty || ruleString == 'ONCE') {
      print("<== END calculateNextDueDate - Result: null (Not Recurring)");
      return null;
    }

    final tz.TZDateTime currentDueTz;
    try {
      currentDueTz = tz.TZDateTime.from(reminder.nextDueDate, location);
    } catch (e) {
      print(
        "!!!!! ERROR creating TZDateTime from reminder.nextDueDate: ${reminder.nextDueDate}, Location: ${location.name} - $e",
      );
      print("<== END calculateNextDueDate - Result: null (TZDateTime Error)");
      return null;
    }
    print(
      "    CurrentDueTz: ${currentDueTz.toIso8601String()} in ${location.name}",
    );

    // Remove potential "RRULE:" prefix for easier matching
    final normalizedRule =
        ruleString.startsWith('RRULE:') ? ruleString.substring(6) : ruleString;

    // ==================================================
    // !! 手动计算常见规则 !!
    // ==================================================
    try {
      // Add try-catch around manual calculations as well
      if (normalizedRule == 'FREQ=DAILY;INTERVAL=1') {
        final next = currentDueTz.add(const Duration(days: 1));
        print(
          "<== END calculateNextDueDate (Manual Daily) - Result: ${next.toIso8601String()}",
        );
        return next;
      }
      // --- 手动计算每周 ---
      else if (normalizedRule.startsWith('FREQ=WEEKLY;INTERVAL=1;BYDAY=')) {
        final daysPart = normalizedRule.split('BYDAY=')[1];
        final targetWeekdays = daysPart.split(','); // ["MO", "WE", "FR"]
        // Map RRULE weekdays (MO=0..SU=6) to Dart DateTime weekdays (Mon=1..Sun=7)
        const rruleToDartWeekday = {
          'MO': 1,
          'TU': 2,
          'WE': 3,
          'TH': 4,
          'FR': 5,
          'SA': 6,
          'SU': 7,
        };
        final targetDartWeekdays =
            targetWeekdays
                .map((day) => rruleToDartWeekday[day.toUpperCase()])
                .whereNotNull() // Filter out invalid days
                .toSet(); // Use a Set for efficient lookup

        if (targetDartWeekdays.isNotEmpty) {
          var nextDate =
              currentDueTz; //.add(const Duration(days: 1)); // Start searching from the day *after* current due date
          for (int i = 0; i < 8; i++) {
            // Search max 7 days ahead + 1 just in case
            nextDate = nextDate.add(const Duration(days: 1)); // Check next day
            if (targetDartWeekdays.contains(nextDate.weekday)) {
              print(
                "<== END calculateNextDueDate (Manual Weekly) - Result: ${nextDate.toIso8601String()}",
              );
              return nextDate;
            }
          }
          // Should not happen if targetDartWeekdays is not empty, but as fallback:
          print(
            "Warning: Manual weekly calculation couldn't find next day within 7 days.",
          );
        }
      }
      // --- 手动计算每月特定日期 ---
      else if (normalizedRule.startsWith(
        'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=',
      )) {
        final dayPart = normalizedRule.split('BYMONTHDAY=')[1];
        final targetDayOfMonth = int.tryParse(dayPart);

        if (targetDayOfMonth != null &&
            targetDayOfMonth >= 1 &&
            targetDayOfMonth <= 31) {
          var nextDate = currentDueTz;
          // Loop through subsequent months until a valid date is found
          for (int i = 0; i < 13; i++) {
            // Check next 12 months + current
            // Move to the next month (handle year change)
            int nextMonth = nextDate.month + 1;
            int nextYear = nextDate.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }

            // Try to construct the date in the next month with the target day
            // Need to check if targetDayOfMonth is valid for that month
            int lastDayOfMonth =
                DateTime(
                  nextYear,
                  nextMonth + 1,
                  0,
                ).day; // Get last day of next month
            int dayToUse =
                targetDayOfMonth > lastDayOfMonth
                    ? lastDayOfMonth
                    : targetDayOfMonth;

            final potentialNextDate = tz.TZDateTime(
              location,
              nextYear,
              nextMonth,
              dayToUse,
              currentDueTz.hour, // Keep the original time
              currentDueTz.minute,
              currentDueTz.second,
            );

            // Ensure the potential date is strictly after the current one
            if (potentialNextDate.isAfter(currentDueTz)) {
              print(
                "<== END calculateNextDueDate (Manual Monthly) - Result: ${potentialNextDate.toIso8601String()}",
              );
              return potentialNextDate;
            }
            // If not after, update nextDate to the beginning of the *next* potential month to continue search
            nextDate = tz.TZDateTime(location, nextYear, nextMonth, 1);
          }
          print(
            "Warning: Manual monthly calculation couldn't find next date within 13 months.",
          );
        }
      }
    } catch (e) {
      print(
        "!!!!! ERROR during manual calculation for rule '$normalizedRule': $e",
      );
    }

    // ==================================================
    // 对于其他复杂或未手动处理的规则，才尝试使用 rrule 库 (带 take 限制)
    // ==================================================
    print(
      "    Attempting calculation using rrule library for potentially complex rule: $ruleString ...",
    );
    try {
      print("--> BEFORE RecurrenceRule.fromString");
      final rrule = RecurrenceRule.fromString(
        ruleString,
      ); // Use original string
      print(
        "<-- AFTER RecurrenceRule.fromString - Parsed Frequency: ${rrule.frequency}",
      );

      print("--> BEFORE rrule.getAllInstances");
      final searchStart = currentDueTz.subtract(
        const Duration(microseconds: 1),
      );
      print("    Using searchStart: ${searchStart.toIso8601String()}");

      final instances = rrule.getAllInstances(start: searchStart).take(5);

      final DateTime? nextInstance = instances.firstWhereOrNull(
        (dt) => dt.isAfter(currentDueTz),
      );

      print("<-- AFTER rrule calculation attempt - Result: $nextInstance");

      if (nextInstance != null) {
        final tz.TZDateTime resultTzDateTime;
        if (nextInstance is tz.TZDateTime) {
          resultTzDateTime =
              nextInstance.location == location
                  ? nextInstance
                  : tz.TZDateTime.from(nextInstance, location);
        } else {
          resultTzDateTime = tz.TZDateTime.from(nextInstance, location);
        }
        print(
          "<== END calculateNextDueDate (rrule) - Result: ${resultTzDateTime.toIso8601String()}",
        );
        return resultTzDateTime;
      } else {
        print(
          "    rrule (limited search) could not find next instance for rule: $ruleString after $currentDueTz in the first 5 occurrences.",
        );
        print(
          "<== END calculateNextDueDate (rrule) - Result: null (No next instance found in limited search)",
        );
        return null;
      }
    } catch (e) {
      print(
        "!!!!! ERROR in calculateNextDueDate (rrule) for rule '$ruleString': $e",
      );
      print("<== END calculateNextDueDate - Result: null (Error)");
      return null;
    }
  }

  /// Formats the RRULE string into a user-friendly Chinese description.
  static String formatFrequencyRuleForDisplay(String? ruleString) {
    if (ruleString == null || ruleString.isEmpty || ruleString == 'ONCE') {
      return '仅一次';
    }
    try {
      // !! 关键修复：先去除 "RRULE:" 前缀再解析 !!
      final normalizedRuleString =
          ruleString.startsWith('RRULE:')
              ? ruleString.substring(6)
              : ruleString;

      // 检查清理后的字符串是否为空（例如，如果原始字符串只有 "RRULE:"）
      if (normalizedRuleString.isEmpty) {
        print(
          "Warning: Empty rule string after removing 'RRULE:' prefix from '$ruleString'",
        );
        return ruleString; // 返回原始字符串作为回退
      }

      final RecurrenceRule rrule = RecurrenceRule.fromString(
        normalizedRuleString,
      );

      // --- Fallback to Manual Formatting (因为 toText 可能不可靠或格式不理想) ---
      final freq = rrule.frequency;
      final int interval = rrule.interval ?? 1;
      final byWeekDays = rrule.byWeekDays; // List<ByWeekDayEntry>
      final byMonthDays = rrule.byMonthDays; // List<int>

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
          return ruleString; // Should not happen if parsed
      }

      String intervalText = interval > 1 ? "每 $interval " : "每";
      String detailsText = "";

      if (freq == Frequency.weekly && byWeekDays.isNotEmpty) {
        const List<String> days = ['一', '二', '三', '四', '五', '六', '日']; // 索引 0-6
        List<int> dayIndices = byWeekDays.map((entry) => entry.day).toList();
        dayIndices.sort();
        List<String> selectedDays =
            dayIndices
                .where((index) => index >= 0 && index < days.length)
                .map((index) => days[index])
                .toList();
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
      return ruleString; // 返回原始字符串作为回退
    }
  }
}
