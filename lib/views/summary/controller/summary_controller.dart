import 'dart:io';

import 'package:doda_work/core/api/model/basic_success_model.dart';
import 'package:doda_work/routes/routes.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/services/api.dart';
import '../../../core/utils/basic_import.dart';
import '../model/summary_model.dart';

class SummaryController extends GetxController {
  final TextEditingController noteController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAccept = false.obs;

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomSnackBar.error('Failed to pick image');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      CustomSnackBar.error('Failed to capture image');
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  RxString submitedProveStatus = ''.obs;

  Future<BasicSuccessModel> acceptApprove({required String id}) async {
    return await ApiRequest.patch(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: 'service-requests/update-status',
      isLoading: isLoadingAccept,
      showSuccessSnackBar: true,
      body: {'requestId': id, 'status': 'APPROVED'},
      onSuccess: (result) {
        Get.offAllNamed(Routes.navigationScreen);
      },
    );
  }

  // review

  final TextEditingController reviewController = TextEditingController();
  final RxDouble rating = 0.0.obs;
  final RxBool isLoadingReview = false.obs;

  void showReviewBottomSheet({required String id, required String providerId}) {
    reviewController.clear();
    rating.value = 0.0;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          left: Dimensions.horizontalSize,
          right: Dimensions.horizontalSize,
          top: Dimensions.verticalSize,
          bottom:
              MediaQuery.of(Get.context!).viewInsets.bottom +
              Dimensions.verticalSize,
        ),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius * 2),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: mainMin,
            crossAxisAlignment: crossStart,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CustomColors.disableColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Space.height.v20,
              TextWidget(
                'Approve & Review',
                fontSize: Dimensions.titleLarge,
                fontWeight: FontWeight.bold,
              ),
              Space.height.v5,
              TextWidget(
                'Would you like to leave a review? (Optional)',
                fontSize: Dimensions.bodyMedium,
                color: CustomColors.grayShade,
              ),
              Space.height.v20,

              // Rating
              TextWidget(
                'Rating',
                fontSize: Dimensions.titleSmall,
                fontWeight: FontWeight.w600,
              ),
              Space.height.v10,
              Obx(
                () => Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => rating.value = (index + 1).toDouble(),
                      child: Icon(
                        index < rating.value ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 32.h,
                      ),
                    );
                  }),
                ),
              ),
              Space.height.v20,

              // Review input
              PrimaryInputFieldWidget(
                controller: reviewController,
                hintText: 'Write your review...',
                label: 'Review',
                maxLines: 3,
                requiredField: false,
              ),
              Space.height.v20,

              // Buttons
              Obx(
                () => PrimaryButtonWidget(
                  title: 'Approve with Review',
                  isLoading: isLoadingReview.value,
                  onPressed: () =>
                      _submitReviewAndApprove(id: id, providerId: providerId),
                ),
              ),
              Space.height.v10,
              PrimaryButtonWidget(
                title: 'Approve without Review',
                onPressed: () {
                  Get.back();
                  acceptApprove(id: id);
                },
                buttonColor: Colors.grey.shade200,

                buttonTextColor: CustomColors.blackColor,
              ),
              Space.height.v10,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReviewAndApprove({
    required String id,
    required String providerId,
  }) async {
    if (rating.value == 0.0) {
      CustomSnackBar.error('Please select a rating');
      return;
    }

    await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: 'review/post-review',
      isLoading: isLoadingReview,
      showSuccessSnackBar: true,
      body: {
        'providerId': providerId,
        'review': reviewController.text.trim(),
        'rating': rating.value.toString(),
      },
      onSuccess: (result) {
        Get.back();
        acceptApprove(id: id);
      },
    );
  }

  void showImageSourceOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Dimensions.paddingSize),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius * 2),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: mainMin,
            children: [
              TextWidget(
                'Select Image Source',
                fontSize: Dimensions.titleLarge,
                fontWeight: FontWeight.bold,
              ),
              Space.height.v20,
              ListTile(
                leading: Icon(Icons.photo_library, color: CustomColors.primary),
                title: TextWidget('Gallery', fontSize: Dimensions.bodyLarge),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: CustomColors.primary),
                title: TextWidget('Camera', fontSize: Dimensions.bodyLarge),
                onTap: () {
                  Get.back();
                  pickImageFromCamera();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitCompletion(SummaryModel model) async {
    if (selectedImage.value == null) {
      CustomSnackBar.error('Please attach an image');
      return;
    }

    await ApiRequest.multiMultipartRequest(
      reqType: 'POST',
      fromJson: BasicSuccessModel.fromJson,
      endPoint: 'service-requests/complete',
      isLoading: isLoading,
      showSuccessSnackBar: true,
      body: {'requestId': model.id ?? '', 'notes': noteController.text.trim()},
      files: {'completionProof': selectedImage.value!},
      onSuccess: (result) {
        clearData();
        Get.close(2);
      },
    );
  }

  void clearData() {
    selectedImage.value = null;
    noteController.clear();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
