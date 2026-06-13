import 'dart:io';

import 'package:doda_work/views/profile/controller/profile_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/api/services/api.dart';
import '../../../core/utils/app_storage.dart';
import '../../../core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../model/user_update_profile_model.dart';

class UpdateController extends GetxController {
  // Controllers & focus nodes
  final nameController = TextEditingController();
  final nameFocus = FocusNode();

  final updatedDate = "".obs;

  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  final isEmailValid = false.obs;

  final numberController = TextEditingController();
  final numberFocus = FocusNode();

  // Image picker
  final _imagePicker = ImagePicker();
  final Rx<File?> selectedImg = Rx<File?>(null);

  // Loading state
  RxBool isLoading = false.obs;

  // Location picker
  final Rxn<LatLng> selectedLatLng = Rxn<LatLng>();
  final RxString selectedAddress = "".obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text =
        Get.find<ProfileController>().userProfileModel.value?.data?.name ?? "";
    numberController.text =
        Get.find<ProfileController>()
            .userProfileModel
            .value
            ?.data
            ?.phoneNumber ??
        "";
    updatedDate.value =
        Get.find<ProfileController>()
            .userProfileModel
            .value
            ?.data
            ?.dateOfBirth ??
        "";

    final lat =
        Get.find<ProfileController>().userProfileModel.value?.data?.latitude;
    final lng =
        Get.find<ProfileController>().userProfileModel.value?.data?.longitude;

    if (lat != null && lng != null) {
      selectedLatLng.value = LatLng(double.parse(lat), double.parse(lng));
      _getAddressFromLatLng(
        double.parse(lat),
        double.parse(lng),
      ); // ✅ real address fetch
    }

    emailController.addListener(() {
      final email = emailController.text.trim();
      isEmailValid.value = GetUtils.isEmail(email);
    });
  }

  /// Reverse geocoding
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final apiKey = Platform.isAndroid
          ? ApiEndPoints.googleApiKeyAndroid
          : ApiEndPoints.googleApiKeyIos;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          selectedAddress.value = data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  /// Pick image from gallery
  Future<void> pickImg() async {
    final pickedImg = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImg == null) {
      CustomSnackBar.error('Image not selected');
      return;
    }
    selectedImg.value = File(pickedImg.path);
  }

  Future<UserUpdateProfileModel?> userUpdateProfile() async {
    final Map<String, File?> fileMap = {};

    if (selectedImg.value != null) {
      fileMap['profile_image'] = selectedImg.value;
    }

    final Map<String, String> body = {
      '_method': 'PATCH',
      'name': nameController.text.trim(),
      'phoneNumber': numberController.text.trim(),
      'dateOfBirth': updatedDate.value,
      if (selectedLatLng.value != null)
        'latitude': selectedLatLng.value!.latitude.toString(),
      if (selectedLatLng.value != null)
        'longitude': selectedLatLng.value!.longitude.toString(),
    };

    return await ApiRequest.multiMultipartRequest(
      endPoint: ApiEndPoints.userUpdateProfile,
      token: AppStorage.token,
      reqType: "PATCH",
      isLoading: isLoading,
      body: body,
      files: fileMap,
      // just pass the map
      fromJson: UserUpdateProfileModel.fromJson,
      showSuccessSnackBar: true,
      onSuccess: (_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.offAllNamed(Routes.navigationScreen);
        });
      },
    );
  }
}
