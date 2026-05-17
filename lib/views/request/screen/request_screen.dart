import 'dart:io';

import 'package:doda_work/core/helpers/helpers.dart';
import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/widgets/custom_drop_down_widget.dart';
import 'package:doda_work/widgets/date_picker_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../widgets/location_picker_widget.dart';
import '../../../widgets/notification_icon.dart';
import '../../../widgets/time_picker_widget.dart';
import '../../category/controller/category_controller.dart';
import '../../navigation/controller/navigation_controller.dart';
import '../controller/request_controller.dart';

part '../widget/add_photo_box_widget.dart';
part '../widget/others_field_widget.dart';
part '../widget/request_info_card_widget.dart';
part '../widget/time_and_date_section_widget.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final controller = Get.find<RequestController>();
  final categoryController = Get.find<CategoryController>();
  final descriptionTextController = TextEditingController();
  final phoneTextController = TextEditingController();

  final fromKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: Dimensions.appBarHeight * 2.25,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.currentStep.value > 0) {
                      controller.currentStep.value--;
                    } else {
                      Get.find<NavigationController>().goToProfile();
                    }
                  },
                  child: Row(
                    children: [
                      if (controller.currentStep.value > 0)
                        const Icon(Icons.arrow_back_ios, size: 20),
                      AppBarLogoWidget(
                        onTap: () {
                          if (controller.currentStep.value > 0) {
                            controller.currentStep.value--;
                          } else {
                            Get.find<NavigationController>().goToProfile();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Obx(
                      () => TextWidget(
                        controller.currentStep.value == 2
                            ? 'Request Preview'
                            : 'Service Request',
                        color: CustomColors.blackColor,
                        fontSize: Dimensions.titleLarge,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                /// NOTIFICATION ICON
                NotificationIcon(),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        switch (controller.currentStep.value) {
          case 0:
            return _buildStep1();
          case 1:
            return _buildStep2();
          case 2:
            return _buildStep3Preview();
          default:
            return _buildStep1();
        }
      }),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: fromKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildStepProgress(0),
          Space.height.v20,
          OthersFieldWidget(
            controller: controller,
            requestController: descriptionTextController,
            phoneController: phoneTextController,
            categoryController: categoryController,
            showOnlyInfo: true,
          ),
          Space.height.v30,
          PrimaryButtonWidget(
            title: "Continue",
            onPressed: () {
              if (controller.isStep1Valid(
                phone: phoneTextController.text,
                description: descriptionTextController.text,
              )) {
                controller.currentStep.value = 1;
              }
            },
          ),
          Space.height.v20,
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildStepProgress(1),
        Space.height.v20,
        TimeAndDateSectionWidget(),
        Space.height.betweenInputBox,
        OthersFieldWidget(
          controller: controller,
          requestController: descriptionTextController,
          phoneController: phoneTextController,
          categoryController: categoryController,
          showOnlyLocation: true,
        ),
        Space.height.v5,
        AddPhotoGrid(controller: controller),
        Space.height.v30,
        Row(
          children: [
            Expanded(
              child: PrimaryButtonWidget(
                title: "Back",
                onPressed: () => controller.currentStep.value = 0,
                buttonColor: CustomColors.disableColor,
                buttonTextColor: CustomColors.blackColor,
              ),
            ),
            Space.width.v15,
            Expanded(
              child: PrimaryButtonWidget(
                title: "Preview",
                onPressed: () {
                  if (controller.isStep2Valid()) {
                    controller.currentStep.value = 2;
                  }
                },
              ),
            ),
          ],
        ),
        Space.height.v20,
      ],
    );
  }

  Widget _buildStep3Preview() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildStepProgress(2),
        Space.height.v20,
        RequestPreviewWidget(
          controller: controller,
          description: descriptionTextController.text,
          phone: phoneTextController.text,
        ),
        Space.height.v30,
        Obx(
          () => PrimaryButtonWidget(
            isLoading: controller.isLoading.value,
            title: "Submit Request",
            onPressed: () {
              controller.bookingService(
                customerPhone: phoneTextController.text,
                description: descriptionTextController.text,
              );
            },
          ),
        ),
        Space.height.v10,
        TextButton(
          onPressed: () => controller.currentStep.value = 1,
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
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 4),
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
