part of 'aditional_screen.dart';

class AditionalScreenMobile extends GetView<AditionalController> {
  const AditionalScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var apiKeyMap = Platform.isAndroid
        ? ApiEndPoints.googleApiKeyAndroid
        : ApiEndPoints.googleApiKeyIos;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => AuthAppBar(
            title: controller.currentStep.value == 1
                ? 'Preview Registration'
                : 'Service Provider registration',
            isBack: true,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.defaultHorizontalSize,
                  vertical: 16,
                ),
                child: _buildStepProgress(controller.currentStep.value),
              ),
              Expanded(
                child: controller.currentStep.value == 1
                    ? _buildPreviewStep()
                    : _buildFormStep(context, apiKeyMap),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormStep(BuildContext context, String apiKeyMap) {
    return ListView(
      padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
      children: [
        // Website
        PrimaryInputFieldWidget(
          controller: controller.linkController,
          hintText: 'Website link',
          label: 'Website',
        ),
        Space.height.betweenInputBox,

        // Service Category
        MultiSelectDropDownWidget(
          items: controller.serviceCategoryList.map((e) => e.name).toList(),
          label: "Service Category",
          onChanged: (List<String> selectedNames) {
            controller.selectedServiceList.clear();

            final selectedItems = controller.serviceCategoryList
                .where((item) => selectedNames.contains(item.name))
                .toList();

            controller.selectedServiceList.addAll(
              selectedItems.map((e) => e.id),
            );
          },
        ),

        Space.height.betweenInputBox,
        TextWidget('Select day and set time', fontSize: Dimensions.titleSmall),

        // DAY BUTTON LIST
        Obx(
          () => Wrap(
            spacing: Dimensions.widthSize,
            runSpacing: Dimensions.heightSize * 0.5,
            children: List.generate(controller.dayList.length, (index) {
              final day = controller.dayList[index];
              final isEditing = controller.currentEditingDay.value == day;
              final hasTime = controller.isDaySelected(day);

              return InkWell(
                onTap: () => controller.selectTap(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize,
                    vertical: Dimensions.verticalSize * 0.2,
                  ),
                  decoration: BoxDecoration(
                    color: isEditing
                        ? CustomColors.primary
                        : hasTime
                        ? CustomColors.primary.withValues(alpha: 0.5)
                        : CustomColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWidget(
                        day,
                        color: isEditing || hasTime
                            ? CustomColors.whiteColor
                            : CustomColors.primary,
                      ),

                      if (hasTime && !isEditing) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => controller.removeDayAvailability(day),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: CustomColors.whiteColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        Space.height.betweenInputBox,

        // TIME PICKERS
        Obx(() {
          if (controller.currentEditingDay.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                'Set time for ${controller.currentEditingDay.value}',
                fontSize: Dimensions.titleSmall,
              ),
              Row(
                children: [
                  Expanded(
                    child: TimePickerWidget(
                      label: 'Start Time',
                      onTimeSelected: (time) {
                        controller.startedTime.value = time;
                        controller.saveTimeForCurrentDay();
                      },
                    ),
                  ),
                  Space.width.v10,
                  Expanded(
                    child: TimePickerWidget(
                      label: 'End Time',
                      onTimeSelected: (time) {
                        controller.endTime.value = time;
                        controller.saveTimeForCurrentDay();
                      },
                    ),
                  ),
                ],
              ),
              Space.height.betweenInputBox,
            ],
          );
        }),

        // SHOW AVAILABILITY LIST
        Obx(() {
          final availableDays = controller.getAvailabilityData();
          if (availableDays.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                'Your Availability:',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.titleSmall,
              ),
              const SizedBox(height: 8),
              ...availableDays.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      TextWidget(
                        '${item['day']}: ',
                        fontWeight: FontWeight.w500,
                      ),
                      TextWidget('${item['startTime']} - ${item['endTime']}'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            controller.removeDayAvailability(item['day']),
                      ),
                    ],
                  ),
                ),
              ),
              Space.height.betweenInputBox,
            ],
          );
        }),

        // ADDRESS PICK
        Row(
          children: [
            TextWidget(
              "What is the service address",
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              fontSize: Dimensions.titleSmall,
              fontWeight: FontWeight.w500,
              color: CustomColors.blackColor.withAlpha(888),
            ),
          ],
        ),
        SizedBox(height: Dimensions.spaceBetweenInputTitleAndBox * 0.6),
        Obx(() {
          final isPick = controller.selectedAddress.isNotEmpty;
          return GestureDetector(
            onTap: () {
              Get.to(
                () => LocationPickerWidget(
                  selectedAddress: controller.selectedAddress,
                  selectedLatLng: controller.selectedLatLng,
                  googleApiKey: apiKeyMap,
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPick
                      ? CustomColors.primary
                      : CustomColors.disableColor,
                  width: 1.4,
                ),
              ),
              child: Text(
                isPick
                    ? controller.selectedAddress.value
                    : "Pick Service Address",
                style: TextStyle(
                  fontSize: Dimensions.titleSmall,
                  fontWeight: FontWeight.w500,
                  color: isPick
                      ? CustomColors.blackColor
                      : CustomColors.blackColor.withAlpha(888),
                ),
              ),
            ),
          );
        }),
        Space.height.betweenInputBox,

        // CONTACT PERSON
        PrimaryInputFieldWidget(
          controller: controller.contactPersonController,
          hintText: '+1 (XXX) XXX-XXXX',
          label: 'Contact Number',
          keyBoardType: TextInputType.phone,
          onChanged: (value) {
            final formatted = Helpers.formatCanadianPhone(value);
            if (formatted != value) {
              controller.contactPersonController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        Space.height.betweenInputBox,

        TextWidget(
          'License & certificate',
          fontWeight: FontWeight.w500,
          fontSize: Dimensions.titleMedium,
          padding: const EdgeInsets.only(bottom: 8),
        ),

        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var photo in controller.photos)
                Container(
                  width: 100.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.8,
                    ),
                    image: DecorationImage(
                      image: FileImage(photo),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: controller.pickImage,
                child: Container(
                  width: 100.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.8,
                    ),
                    border: Border.all(color: Colors.orange),
                    color: Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.orange,
                      size: Dimensions.iconSizeLarge,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        Space.height.v30,
        PrimaryButtonWidget(
          title: 'Continue to Preview',
          onPressed: () {
            if (controller.isFormValid()) {
              controller.currentStep.value = 1;
            }
          },
        ),
        Space.height.v20,
      ],
    );
  }

  Widget _buildPreviewStep() {
    return ListView(
      padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
      children: [
        ProviderPreviewWidget(controller: controller),
        Space.height.v30,
        Obx(
          () => PrimaryButtonWidget(
            title: 'Submit Application',
            isLoading: controller.providerRegIsLoading.value,
            onPressed: controller.providerRegisterProcess,
          ),
        ),
        Space.height.v10,
        TextButton(
          onPressed: () => controller.currentStep.value = 0,
          child: TextWidget(
            "Back to Edit",
            color: CustomColors.grayShade,
            fontWeight: FontWeight.w500,
          ),
        ),
        Space.height.v20,
      ],
    );
  }

  Widget _buildStepProgress(int step) {
    return Row(
      children: List.generate(2, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= step
                  ? CustomColors.primary
                  : CustomColors.disableColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}
