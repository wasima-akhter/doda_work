import 'dart:io';

import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/routes/routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../category/controller/category_controller.dart';

class RequestController extends GetxController {
  final Rxn<DateTime> startDateTime = Rxn<DateTime>();
  final Rxn<DateTime> endDateTime = Rxn<DateTime>();
  final RxString selectedPriority = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedSubCategoryId = ''.obs;
  final RxInt currentStep = 0.obs; // 0: Info, 1: Logistics/Photos, 2: Preview

  final CategoryController categoryController = Get.find<CategoryController>();

  final RxString selectedAddress = "".obs;
  final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();

  void onCategorySelected(String categoryId) {
    selectedCategoryId.value = categoryId;
    final selectedCat = categoryController.allCategory.firstWhereOrNull(
      (c) => c.id == categoryId,
    );
    categoryController.availableSubcategories
      ..clear()
      ..addAll(selectedCat?.subcategories ?? []);
    selectedSubCategoryId.value = '';
  }

  void onSubCategorySelected(String subCategoryId) {
    selectedSubCategoryId.value = subCategoryId;
  }

  bool isStep1Valid({required String phone, required String description}) {
    if (selectedCategoryId.value.isEmpty) {
      _showSnackbar("Missing Field", "Please select a service category.");
      return false;
    }
    if (selectedSubCategoryId.value.isEmpty) {
      _showSnackbar("Missing Field", "Please select a subcategory.");
      return false;
    }
    if (selectedPriority.value.isEmpty) {
      _showSnackbar("Missing Field", "Please select a service priority.");
      return false;
    }
    if (phone.isEmpty) {
      _showSnackbar("Missing Field", "Please enter contact number.");
      return false;
    }
    if (description.isEmpty) {
      _showSnackbar("Missing Field", "Please enter issue description.");
      return false;
    }
    return true;
  }

  bool isStep2Valid() {
    if (startDateTime.value == null || endDateTime.value == null) {
      _showSnackbar("Missing Field", "Please select both start and end dates.");
      return false;
    }
    if (selectedLatLng.value == null || selectedAddress.value.isEmpty) {
      _showSnackbar("Missing Location", "Please select your service address.");
      return false;
    }
    if (photos.isEmpty) {
      _showSnackbar("Missing Image", "Please add at least one photo.");
      return false;
    }
    return true;
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  RxList<File> photos = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      photos.add(File(pickedFile.path));
    }
  }

  void resetForm() {
    startDateTime.value = null;
    endDateTime.value = null;

    selectedPriority.value = '';
    selectedCategoryId.value = '';
    selectedSubCategoryId.value = '';

    categoryController.availableSubcategories.clear();

    selectedLatLng.value = null;
    selectedAddress.value = '';

    photos.clear();
    currentStep.value = 0;
  }

  final RxBool isLoading = false.obs;

  Future<void> bookingService({
    required String customerPhone,
    required String description,
  }) async {
    final Map<String, String> payload = {
      "serviceCategory": selectedCategoryId.value,
      "subcategory": selectedSubCategoryId.value,
      "priority": selectedPriority.value,
      "startDate": DateFormat('yyyy-MM-dd').format(startDateTime.value!),
      "endDate": DateFormat('yyyy-MM-dd').format(endDateTime.value!),
      "startTime": DateFormat('HH:mm').format(startDateTime.value!),
      "endTime": DateFormat('HH:mm').format(endDateTime.value!),
      "address": selectedAddress.value,
      "latitude": selectedLatLng.value?.latitude.toString() ?? "",
      "longitude": selectedLatLng.value?.longitude.toString() ?? "",
      "customerPhone": customerPhone,
      "description": description,
    };

    try {
      isLoading.value = true;
      final response = await ApiClient.multipartRequest(
        url: ApiEndPoints.serviceCreate(),
        body: payload,
        reqType: "POST",
        multipartBody: photos
            .map((file) => MultipartBody("attachments", file))
            .toList(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Your booking has been submitted successfully.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        resetForm();
        Get.offAllNamed(Routes.navigationScreen);
        // Get.find<NavigationController>().goToHome();
      } else {
        Get.snackbar(
          "Failed",
          "Booking submission failed. Try again.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  final RxString postalCode = ''.obs;

  // Future<void> fetchPostalCode() async {
  //   if (selectedLatLng.value == null) return;
  //
  //   final lat = selectedLatLng.value!.latitude;
  //   final lng = selectedLatLng.value!.longitude;
  //
  //   try {
  //     final placemarks = await placemarkFromCoordinates(lat, lng);
  //
  //     if (placemarks.isNotEmpty) {
  //       postalCode.value = placemarks.first.postalCode ?? '';
  //     }
  //   } catch (e) {
  //     postalCode.value = '';
  //     debugPrint('Error fetching postal code: $e');
  //   }
  // }
}
