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

TimeOfDay parsePickedTime(String time) {
  final parts = time.split(":");
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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

//
String formatTime(String time24) {
  final parts = time24.split(":");
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  final time = TimeOfDay(hour: hour, minute: minute);

  final now = DateTime(0, 0, 0, time.hour, time.minute);

  final formatted = TimeOfDay.fromDateTime(now).format(Get.context!);
  return formatted;
}
