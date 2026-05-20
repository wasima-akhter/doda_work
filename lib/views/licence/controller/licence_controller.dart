import 'dart:io';

import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/views/profile/controller/profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class LicenceController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxList<File> photos = <File>[].obs; // New picked photos
  final RxList<String> oldPhotos = <String>[].obs; // Existing images from API
  final RxBool isUpdateLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    oldPhotos.addAll(
      Get.find<ProfileController>()
              .providerProfileModel
              .value
              ?.data
              .attachments ??
          [],
    );
  }

  // ---------------- Pick Image ----------------
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      photos.add(File(pickedFile.path));
    }
  }

  // ---------------- Delete old image ----------------
  void removeOldImage(String url) {
    oldPhotos.remove(url);
  }

  // ---------------- Delete new picked image ----------------
  void removeNewImage(File file) {
    photos.remove(file);
  }

  // ---------------- Update Profile ----------------
  Future<void> updateProfile({required Map<String, String> body}) async {
    try {
      isUpdateLoading.value = true;

      // IMPORTANT: Send old image URLs back to server
      body["old_images"] = oldPhotos.join(",");

      // Attach new picked photos as multipart
      final List<MultipartBody> multipartBody = photos
          .map((file) => MultipartBody("attachments", file))
          .toList();

      final response = await ApiClient.multipartRequest(
        url: ApiEndPoints.updateProviderLicence,
        body: body,
        multipartBody: multipartBody,
        reqType: "PATCH",
      );

      if (response.statusCode == 200 &&
          response.body["success"] == true &&
          response.body["data"] != null) {
        final message = response.body["data"]["message"] ?? "Update successful";

        Get.snackbar(
          "Success",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        photos.clear(); // new images clear after success
      } else {
        Get.snackbar(
          "Error",
          "Update failed. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdateLoading.value = false;
    }
  }
}
