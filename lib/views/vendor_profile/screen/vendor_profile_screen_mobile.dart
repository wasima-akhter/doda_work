import 'dart:io';

import 'package:doda_work/views/profile/controller/profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/utils/basic_import.dart';
import '../../../core/utils/extensions.dart';
import '../../../widgets/auth_app_bar.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/location_picker_widget.dart';
import '../../request/widget/category_widget.dart';
import '../controller/vendor_profile_controller.dart';

class VendorProfileScreenMobile extends GetView<VendorProfileController> {
  const VendorProfileScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var apiKeyMap = Platform.isAndroid
        ? ApiEndPoints.googleApiKeyAndroid
        : ApiEndPoints.googleApiKeyIos;
    return Scaffold(
      appBar: AuthAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? LoadingWidget()
              : ListView(
                  padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
                  children: [
                    Space.height.v20,
                    Center(
                      child: Stack(
                        children: [
                          Obx(
                            () => ClipOval(
                              child: controller.selectedImg.value != null
                                  ? Image.file(
                                      controller.selectedImg.value!,
                                      height: 90.h,
                                      width: 100.w,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          Get.find<ProfileController>()
                                              .providerProfileModel
                                              .value
                                              ?.data
                                              .profileImage ??
                                          "",
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade300,
                                      ),
                                      errorWidget:
                                          (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 110,
                                            color: Colors.grey,
                                          ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 0,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                controller.pickImg();
                              },
                              child: Container(
                                padding: EdgeInsets.all(
                                  Dimensions.paddingSize * 0.1,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CustomColors.whiteColor.withAlpha(
                                      88,
                                    ),
                                  ),
                                  color: CustomColors.primary,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: CustomColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Space.height.betweenInputBox,
                    PrimaryInputFieldWidget(
                      label: "Company Name",
                      controller: controller.nameController,
                      focusNode: controller.nameFocus,
                      hintText: "Enter your company Name",
                    ),

                    Space.height.betweenInputBox,

                    PrimaryInputFieldWidget(
                      controller: controller.contactPersonController,
                      hintText: 'Enter Name of contact person',
                      label: 'Contact Person',
                    ),
                    Space.height.betweenInputBox,

                    PrimaryInputFieldWidget(
                      controller: controller.coveredRadius,
                      hintText: 'Enter Covered Aria Km',
                      label: 'Covered Aria Km',
                      keyBoardType: TextInputType.number,
                    ),
                    Space.height.betweenInputBox,
                    PrimaryInputFieldWidget(
                      controller: controller.websiteController,
                      hintText: 'Enter website Link',
                      label: 'Website Link',
                      keyBoardType: TextInputType.number,
                    ),
                    Space.height.betweenInputBox,

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
                    SizedBox(
                      height: Dimensions.spaceBetweenInputTitleAndBox * 0.6,
                    ),
                    Obx(() {
                      final isPick = controller.selectedAddress.isNotEmpty;
                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => LocationPickerWidget(
                              selectedAddress: controller.selectedAddress,
                              selectedLatLng: controller.selectedLatLng,
                              googleApiKey: apiKeyMap,
                              initialLatLng: LatLng(23.8103, 90.4125),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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

                    // CustomDropDownWidget(
                    //   label: 'Service Category',
                    //   hint: 'Select Service Category',
                    //   // show the name in the dropdown
                    //   items: controller.serviceCategoryList.map((e) => e.name).toList(),
                    //   onChanged: (value) {
                    //     var selectedItem = controller.serviceCategoryList.firstWhere(
                    //       (element) => element.name == value,
                    //     );
                    //     controller.selectedServiceList.add(selectedItem.id);
                    //   },
                    // ),
                    MultiSelectDropDownWidget(
                      items: controller.serviceCategoryList
                          .map((e) => e.name)
                          .toList(),
                      label: "Service Category",
                      initialValues: controller.serviceCategoryList
                          .where(
                            (e) =>
                                controller.selectedServiceList.contains(e.id),
                          )
                          .map((e) => e.name)
                          .toList(),
                      onChanged: (List<String> selectedNames) {
                        controller.selectedServiceList.clear();

                        final selectedItems = controller.serviceCategoryList
                            .where((item) => selectedNames.contains(item.name))
                            .toList();

                        controller.selectedServiceList.addAll(
                          selectedItems.map((e) => e.id),
                        );

                        debugPrint(
                          "✅ Selected IDs: ${controller.selectedServiceList}",
                        );
                      },
                    ),
                    Space.height.betweenInputBox,
                    Space.height.betweenInputBox,

                    Obx(
                      () => PrimaryButtonWidget(
                        isLoading: controller.isLoading.value,
                        title: 'Update',
                        onPressed: () {
                          controller.vendorUpdateProfile();
                        },
                      ),
                    ),
                    Space.height.betweenInputBox,
                  ],
                ),
        ),
      ),
    );
  }
}
