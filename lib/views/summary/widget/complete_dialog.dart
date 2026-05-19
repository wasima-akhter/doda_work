import 'package:doda_work/views/summary/controller/summary_controller.dart';
import 'package:doda_work/views/summary/model/summary_model.dart';

import '../../../core/utils/basic_import.dart';

class CompleteTaskDialog extends GetView<SummaryController> {
  final SummaryModel model;

  const CompleteTaskDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(Dimensions.paddingSize),
                constraints: BoxConstraints(
                  maxWidth: 500,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: mainMin,
                  crossAxisAlignment: crossStart,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: mainSpaceBet,
                      children: [
                        TextWidget(
                          'Complete Task',
                          fontSize: Dimensions.headlineSmall,
                          fontWeight: FontWeight.bold,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            controller.clearData();
                            Get.back();
                          },
                        ),
                      ],
                    ),
                    Space.height.v20,

                    // Image attachment section
                    TextWidget(
                      'Attach Image *',
                      fontSize: Dimensions.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                    Space.height.v10,

                    // Image picker button
                    InkWell(
                      onTap: () => controller.showImageSourceOptions(context),
                      child: Container(
                        width: double.infinity,
                        height: Dimensions.inputBoxHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: CustomColors.disableColor),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: mainCenter,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: CustomColors.primary,
                              size: Dimensions.iconSizeLarge,
                            ),
                            Space.width.v10,
                            TextWidget(
                              'Add Image',
                              color: CustomColors.primary,
                              fontSize: Dimensions.bodyLarge,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Space.height.v15,

                    // Selected image preview
                    Obx(() {
                      if (controller.selectedImage.value == null) {
                        return SizedBox.shrink();
                      }

                      return SizedBox(
                        height: 120.h,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius,
                              ),
                              child: Image.file(
                                controller.selectedImage.value!,
                                width: 100.w,
                                height: 100.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: CustomColors.rejected,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: Dimensions.iconSizeDefault,
                                    color: CustomColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    Obx(
                      () => controller.selectedImage.value != null
                          ? Space.height.v20
                          : SizedBox.shrink(),
                    ),

                    // Notes section
                    TextWidget(
                      'Notes (Optional)',
                      fontSize: Dimensions.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                    Space.height.v10,
                    TextField(
                      controller: controller.noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes...',
                        hintStyle: TextStyle(
                          color: CustomColors.disableColor,
                          fontSize: Dimensions.bodyMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                          borderSide: BorderSide(
                            color: CustomColors.disableColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                          borderSide: BorderSide(
                            color: CustomColors.disableColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                          borderSide: BorderSide(color: CustomColors.primary),
                        ),
                      ),
                    ),
                    Space.height.v20,

                    // Action buttons
                    Obx(
                      () => Row(
                        mainAxisAlignment: mainEnd,
                        children: [
                          TextButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.clearData();
                                    Get.back();
                                  },
                            child: TextWidget(
                              'Cancel',
                              color: CustomColors.grayShade,
                              fontSize: Dimensions.bodyLarge,
                            ),
                          ),
                          Space.width.v10,
                          ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.submitCompletion(model),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSize * 1.5,
                                vertical: Dimensions.heightSize * 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius,
                                ),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      color: CustomColors.whiteColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : TextWidget(
                                    'Submit',
                                    color: CustomColors.whiteColor,
                                    fontSize: Dimensions.bodyLarge,
                                    fontWeight: FontWeight.w600,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
