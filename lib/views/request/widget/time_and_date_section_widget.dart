part of '../screen/request_screen.dart';

class TimeAndDateSectionWidget extends GetView<RequestController> {
  const TimeAndDateSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          'Preferred Date and Time',
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w500,
          color: CustomColors.blackColor.withAlpha(888),
        ),
        SizedBox(height: Dimensions.spaceBetweenInputTitleAndBox * 0.6),

        Obx(
          () => Row(
            children: [
              Expanded(
                child: DatePickerWidget(
                  hint: "Select date",
                  label: "Start Date",
                  minDate: DateTime.now(),
                  initialDate: controller.startDateTime.value,

                  onDateSelected: (selected) {
                    debugPrint('START DATE PICKED => $selected');

                    controller.startDateTime.value = selected;
                    if (controller.endDateTime.value != null &&
                        controller.endDateTime.value!.isBefore(selected)) {
                      controller.endDateTime.value = null;
                    }

                    debugPrint(
                      'START DATE SAVED => ${controller.startDateTime.value}',
                    );
                  },
                ),
              ),
              Space.width.v10,
              Expanded(
                child: DatePickerWidget(
                  hint: "Select date",
                  label: "End Date",
                  minDate: controller.startDateTime.value,
                  initialDate: controller.endDateTime.value,
                  onDateSelected: (selected) {
                    controller.endDateTime.value = selected;
                  },
                ),
              ),
            ],
          ),
        ),

        Space.height.betweenInputBox,
        Obx(() {
          final startTime = controller.startDateTime.value;
          final endTime = controller.endDateTime.value;

          final formattedStart = startTime != null
              ? DateFormat('hh:mm a').format(startTime)
              : null;

          final formattedEnd = endTime != null
              ? DateFormat('hh:mm a').format(endTime)
              : null;

          return Row(
            children: [
              Expanded(
                child: TimePickerWidget(
                  label: 'Start Time',
                  text: formattedStart,
                  // onTimeSelected: (timeStr) {
                  //   if (controller.startDateTime.value != null) {
                  //     final parts = timeStr.split(RegExp(r'[: ]'));
                  //     int hour = int.parse(parts[0]);
                  //     final int minute = int.parse(parts[1]);
                  //     final bool isPm =
                  //         parts.length > 2 && parts[2].toUpperCase() == 'PM';
                  //     if (isPm && hour != 12) hour += 12;
                  //     if (!isPm && hour == 12) hour = 0;
                  //     final old = controller.startDateTime.value!;
                  //     controller.startDateTime.value = DateTime(
                  //       old.year,
                  //       old.month,
                  //       old.day,
                  //       hour,
                  //       minute,
                  //     );
                  //   }
                  // },
                  onTimeSelected: (timeStr) {
                    final parts = timeStr.split(RegExp(r'[: ]'));
                    int hour = int.parse(parts[0]);
                    final int minute = int.parse(parts[1]);
                    final bool isPm =
                        parts.length > 2 && parts[2].toUpperCase() == 'PM';

                    if (isPm && hour != 12) hour += 12;
                    if (!isPm && hour == 12) hour = 0;

                    final baseDate =
                        controller.startDateTime.value ?? DateTime.now();

                    controller.startDateTime.value = DateTime(
                      baseDate.year,
                      baseDate.month,
                      baseDate.day,
                      hour,
                      minute,
                    );
                  },
                ),
              ),
              Space.width.v10,
              Expanded(
                child: TimePickerWidget(
                  label: 'End Time',
                  text: formattedEnd,
                  onTimeSelected: (timeStr) {
                    final parts = timeStr.split(RegExp(r'[: ]'));
                    int hour = int.parse(parts[0]);
                    final int minute = int.parse(parts[1]);
                    final bool isPm =
                        parts.length > 2 && parts[2].toUpperCase() == 'PM';

                    if (isPm && hour != 12) hour += 12;
                    if (!isPm && hour == 12) hour = 0;

                    final baseDate =
                        controller.endDateTime.value ??
                        controller.startDateTime.value ??
                        DateTime.now();

                    controller.endDateTime.value = DateTime(
                      baseDate.year,
                      baseDate.month,
                      baseDate.day,
                      hour,
                      minute,
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
