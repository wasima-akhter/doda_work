import 'package:intl/intl.dart';

import '../utils/basic_import.dart';

class Helpers {
  static String formatCanadianPhone(String input) {
    // Remove everything except digits
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading 1 if present
    if (digits.startsWith('1')) {
      digits = digits.substring(1);
    }

    // Limit to 10 digits
    if (digits.length > 10) digits = digits.substring(0, 10);

    String result = '+1 ';

    if (digits.isEmpty) return '';

    if (digits.length <= 3) {
      result += '($digits';
    } else if (digits.length <= 6) {
      result += '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    } else {
      result +=
          '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return result;
  }

  static DateTime _toBDTime(String timestamp) {
    final utcTime = DateTime.parse(timestamp).toUtc();
    return utcTime.add(const Duration(hours: 6));
  }

  // Format timestamp for chat display
  static String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return DateFormat('hh:mm a').format(DateTime.now().toLocal());
    }

    try {
      final bdTime = _toBDTime(timestamp);
      final now = DateTime.now().toUtc().add(
        const Duration(hours: 6),
      ); // current BD time
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(bdTime.year, bdTime.month, bdTime.day);

      // Today → only time
      if (messageDate == today) {
        return DateFormat('hh:mm a').format(bdTime);
      }

      // Yesterday → "Yesterday hh:mm a"
      final yesterday = today.subtract(const Duration(days: 1));
      if (messageDate == yesterday) {
        return "Yesterday ${DateFormat('hh:mm a').format(bdTime)}";
      }

      // This week → Weekday + time
      final diff = today.difference(messageDate).inDays;
      if (diff < 7) {
        return DateFormat('EEEE hh:mm a').format(bdTime);
      }

      // Older → full date
      return DateFormat('dd MMM, hh:mm a').format(bdTime);
    } catch (e) {
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  static String formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return DateFormat('dd MMM yyyy').format(DateTime.now());
    }

    try {
      final bdTime = _toBDTime(timestamp);
      return DateFormat('dd MMM yyyy').format(bdTime);
    } catch (e) {
      return DateFormat('dd MMM yyyy').format(DateTime.now());
    }
  }

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

Future<TimeOfDay?> pickAppTime(BuildContext context, TimeOfDay initial) {
  return showTimePicker(
    context: context,
    initialTime: initial,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: CustomColors.primary, // header + selected time
            onPrimary: CustomColors.whiteColor,
            onSurface: CustomColors.blackColor,

            secondary: CustomColors.primary,
          ),

          timePickerTheme: TimePickerThemeData(
            backgroundColor: CustomColors.whiteColor,

            dialBackgroundColor: Colors.grey.shade100,

            hourMinuteTextColor: CustomColors.blackColor,
            hourMinuteColor: Colors.grey.shade200,

            dayPeriodTextColor: CustomColors.blackColor,

            dialHandColor: CustomColors.primary,

            helpTextStyle: TextStyle(
              color: CustomColors.secondaryDarkText,
              fontWeight: FontWeight.w500,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

TimeOfDay parsePickedTime(String time) {
  try {
    // Handles "08:44 AM"
    if (time.toUpperCase().contains('AM') ||
        time.toUpperCase().contains('PM')) {
      final parts = time.split(' ');
      final hm = parts[0].split(':');

      int hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);

      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }

    // Handles "08:44"
    final hm = time.split(':');

    return TimeOfDay(
      hour: int.tryParse(hm[0]) ?? 0,
      minute: int.tryParse(hm[1]) ?? 0,
    );
  } catch (_) {
    return const TimeOfDay(hour: 9, minute: 0);
  }
}

//
String formatTime(String? time) {
  if (time == null || time.isEmpty) return '--';

  try {
    if (time.toUpperCase().contains('AM') ||
        time.toUpperCase().contains('PM')) {
      return time;
    }

    final hm = time.split(':');

    final hour = int.tryParse(hm[0]) ?? 0;
    final minute = int.tryParse(hm[1]) ?? 0;

    final tod = TimeOfDay(hour: hour, minute: minute);

    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';

    int displayHour = tod.hourOfPeriod;
    if (displayHour == 0) displayHour = 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  } catch (_) {
    return time;
  }
}
