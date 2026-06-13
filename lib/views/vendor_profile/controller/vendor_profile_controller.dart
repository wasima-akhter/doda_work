import 'dart:io';

import 'package:doda_work/views/profile/controller/profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/services/api.dart';
import '../../../core/utils/app_storage.dart';
import '../../../core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../../../widgets/success_dialog.dart';
import '../../aditional/model/service_category_model.dart';
import '../model/provider_update_profile_model.dart';

class VendorProfileController extends GetxController {
  static VendorProfileController get to => Get.find<VendorProfileController>();
  //

  final nameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final coveredRadius = TextEditingController();
  final websiteController = TextEditingController();
  final nameFocus = FocusNode();
  final locationController = TextEditingController();
  final locationFocus = FocusNode();
  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  final numberController = TextEditingController();
  final numberFocus = FocusNode();

  // Observables
  final isEmailValid = false.obs;
  final Rx<File?> selectedImg = Rx(null);
  final RxBool isLoading = false.obs;
  final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();
  final RxString selectedAddress = "".obs;
  final RxList selectedServiceList = [].obs;
  /*
  @override
  void onInit() {
    super.onInit();

    getServiceCategory();

    // Debug: Print current storage state
    debugPrint('🔐 Storage State:');
    debugPrint(
      '   Token: ${AppStorage.token.isNotEmpty ? "Present" : "Empty"}',
    );
    debugPrint('   Token: ${AppStorage.token}');
    debugPrint('   Is Vendor: ${AppStorage.isVendor}');
    debugPrint('   Is Logged In: ${AppStorage.isLoggedIn}');

    nameController.text =
        Get.find<ProfileController>()
            .providerProfileModel
            .value
            ?.data
            .companyName ??
        "";
    contactPersonController.text =
        Get.find<ProfileController>()
            .providerProfileModel
            .value
            ?.data
            .contactPerson ??
        "";
    coveredRadius.text =
        Get.find<ProfileController>()
            .providerProfileModel
            .value
            ?.data
            .coveredRadius
            .toString() ??
        "";
    websiteController.text =
        Get.find<ProfileController>().providerProfileModel.value?.data.website
            .toString() ??
        "";
    selectedAddress.value =
        Get.find<ProfileController>()
            .providerProfileModel
            .value
            ?.data
            .serviceLocation ??
        "";

    final lat =
        Get.find<ProfileController>().providerProfileModel.value?.data.latitude;
    final lng = Get.find<ProfileController>()
        .providerProfileModel
        .value
        ?.data
        .longitude;

    if (lat != null && lng != null) {
      selectedLatLng.value = LatLng(lat, lng);
    }

    selectedServiceList.addAll(
      (Get.find<ProfileController>()
                  .providerProfileModel
                  .value
                  ?.data
                  .serviceCategories ??
              [])
          .map((e) => e.id)
          .toList(),
    );

    emailController.addListener(() {
      final email = emailController.text.trim();
      isEmailValid.value = GetUtils.isEmail(email);
    });

    // workingHours:
    initializeWorkingHours();
  }
*/
  @override
  void onInit() {
    super.onInit();

    getServiceCategory();

    populateFormData();
  }

  Future<void> refreshProfileData() async {
    await Get.find<ProfileController>().getProviderProfile();

    populateFormData();
  }

  void populateFormData() {
    final profile =
        Get.find<ProfileController>().providerProfileModel.value?.data;

    if (profile == null) return;

    nameController.text = profile.companyName ?? "";
    contactPersonController.text = profile.contactPerson ?? "";
    coveredRadius.text = profile.coveredRadius?.toString() ?? "";
    websiteController.text = profile.website ?? "";

    selectedAddress.value = profile.serviceLocation ?? "";

    if (profile.latitude != null && profile.longitude != null) {
      selectedLatLng.value = LatLng(profile.latitude!, profile.longitude!);
    }

    selectedServiceList.assignAll(
      (profile.serviceCategories ?? []).map((e) => e.id).toList(),
    );

    initializeWorkingHours();
  }

  // Other variables
  final _imagePicker = ImagePicker();
  bool isPickingImage = false;
  List<ServiceCategory> serviceCategoryList = [];
  ProviderUpdateProfileModel? providerUpdateProfileModel;

  Future<void> pickImg() async {
    if (isPickingImage) return;

    try {
      isPickingImage = true;
      final pickedImg = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedImg != null) {
        selectedImg.value = File(pickedImg.path);
        debugPrint('✅ Image selected: ${pickedImg.path}');
      } else {
        debugPrint('❌ No image selected');
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      _showSnackBar('Failed to pick image', isError: true);
    } finally {
      isPickingImage = false;
    }
  }

  Future<ServiceCategoryModel> getServiceCategory() async {
    return ApiRequest.get(
      fromJson: ServiceCategoryModel.fromJson,
      endPoint: ApiEndPoints.serviceCategory,
      isLoading: isLoading,
      onSuccess: (result) {
        serviceCategoryList.addAll(result.category);
        debugPrint('✅ Loaded ${serviceCategoryList.length} service categories');
      },
    );
  }

  Future<void> vendorUpdateProfile() async {
    try {
      final token = _getAuthToken();
      if (token == null) return;

      if (!_isUserVendor()) {
        _showSnackBar('Vendor access required', isError: true);
        Get.offAllNamed(Routes.homeScreen);
        return;
      }

      // Prepare request data
      final Map<String, dynamic> body = _prepareRequestBody();
      final Map<String, File?> fileMap = _prepareFileMap();

      debugPrint('🚀 Starting vendor profile update...');
      debugPrint('📦 Body: $body');
      debugPrint('📁 Files: ${fileMap.keys.toList()}');
      debugPrint('🔑 Token: ${token.substring(0, 20)}...');
      debugPrint('🔑 Token full: $token');
      debugPrint('👤 Is Vendor: ${AppStorage.isVendor}');

      await ApiRequest.multiMultipartRequest(
        token: token,
        endPoint: ApiEndPoints.providerUpdateProfile,
        reqType: "PATCH",
        isLoading: isLoading,
        body: body,
        files: fileMap,
        fromJson: ProviderUpdateProfileModel.fromJson,
        showSuccessSnackBar: true,
        onSuccess: (response) {
          _handleSuccessResponse(response);
        },
      );

      debugPrint('✅ Profile update Request successfully');
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleSuccessResponse(ProviderUpdateProfileModel response) {
    debugPrint('🎉 Success Response:');
    debugPrint('   Status Code: ${response.statusCode}');
    debugPrint('   Success: ${response.success}');
    debugPrint('   Message: ${response.message}');
    debugPrint('   Data Message: ${response.data.message}');
    //
    // Get.close(1);
    refreshProfileData();

    //
    // _showSnackBar(response.message.capitalizeFirst ?? '', isError: false);
    // make a popup

    Future.delayed(const Duration(milliseconds: 100), () {
      SuccessDialog.show(
        title: "Request Submitted",
        subtitle:
            "Your update request has been submitted successfully and is awaiting admin approval.",
        onTap: () => Get.back(),
      );
    });

    // fetch profile info again.
    // Get.find<ProfileController>().getProviderProfile();
  }

  String? _getAuthToken() {
    final token = AppStorage.token;
    if (token.isEmpty) {
      _showSnackBar('Please login again', isError: true);
      Get.offAllNamed(Routes.loginScreen);
      return null;
    }
    return token;
  }

  bool _isUserVendor() {
    return AppStorage.isVendor;
  }

  final RxList<WorkingHour> workingHours = <WorkingHour>[].obs;
  void initializeWorkingHours() {
    final profileHours = Get.find<ProfileController>()
        .providerProfileModel
        .value
        ?.data
        .workingHours;

    const allDays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    final apiMap = {
      for (final item in (profileHours ?? [])) (item.day ?? ""): item,
    };

    workingHours.assignAll(
      allDays.map((day) {
        final apiItem = apiMap[day];

        return WorkingHour(
          day: day,
          startTime: apiItem?.startTime ?? "09:00",
          endTime: apiItem?.endTime ?? "18:00",
          isAvailable: apiItem?.isAvailable ?? false,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _prepareRequestBody() {
    return {
      'companyName': nameController.text.trim(),
      'contactPerson': contactPersonController.text.trim(),
      'website': websiteController.text.trim(),
      'coveredRadius': coveredRadius.text.trim(),
      "latitude": selectedLatLng.value!.latitude.toString(),
      "longitude": selectedLatLng.value!.longitude.toString(),
      "serviceCategories": selectedServiceList,
      "serviceLocation": selectedAddress.value,
      // new
      "workingHours": workingHours
          .where((e) => e.isAvailable)
          .map((e) => e.toJson())
          .toList(),
    };
  }

  Map<String, File?> _prepareFileMap() {
    final Map<String, File?> fileMap = {};
    if (selectedImg.value != null) {
      fileMap['profile_image'] = selectedImg.value;
    }
    return fileMap;
  }

  void _handleError(dynamic error) {
    debugPrint('❌ Vendor profile update error: $error');
    debugPrint('❌ Error type: ${error.runtimeType}');

    final errorString = error.toString();

    if (errorString.contains('not authorized') ||
        errorString.contains('401') ||
        errorString.contains('500') ||
        errorString.contains('role')) {
      _handleAuthorizationError();
    } else if (errorString.contains('timeout') ||
        errorString.contains('socket')) {
      _showSnackBar(
        'Network error. Please check your connection.',
        isError: true,
      );
    } else {
      _showSnackBar('Failed to update profile: $error', isError: true);
    }
  }

  void _handleAuthorizationError() {
    _showSnackBar('Session expired. Please login again.', isError: true);

    // FIXED: Using correct clear method
    AppStorage.clear();

    Future.delayed(Duration(milliseconds: 1500), () {
      Get.offAllNamed(Routes.loginScreen);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      CustomSnackBar.error(message);
    } else {
      CustomSnackBar.success(title: message, message: message);
    }
  }

  // Utility method to check if form is valid
  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        contactPersonController.text.isNotEmpty &&
        selectedLatLng.value != null &&
        selectedServiceList.isNotEmpty;
  }
}

class WorkingHour {
  String day;
  String startTime;
  String endTime;
  bool isAvailable;

  WorkingHour({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
    "day": day,
    "startTime": startTime,
    "endTime": endTime,
    "isAvailable": isAvailable,
  };
}
