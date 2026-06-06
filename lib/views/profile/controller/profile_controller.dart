import 'package:doda_work/core/api/services/api.dart';
import 'package:doda_work/core/utils/app_storage.dart';
import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/views/profile/model/user_profile_model.dart';

import '../../../widgets/success_dialog.dart';
import '../../home_vendor/controller/home_vendor_controller.dart';
import '../model/provider_model.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find<ProfileController>();
  RxBool isLoading = false.obs;

  final Rxn<UserProfileModel> userProfileModel = Rxn<UserProfileModel>();
  final Rxn<ProviderProfileModels> providerProfileModel =
      Rxn<ProviderProfileModels>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    if (AppStorage.isProvider) {
      await getProviderProfile();
    } else {
      await getUserProfile();
    }
    isLoading.value = false;
  }

  Future<void> getUserProfile() async {
    try {
      await ApiRequest.get<UserProfileModel>(
        fromJson: UserProfileModel.fromJson,
        endPoint: ApiEndPoints.userProfile,
        isLoading: isLoading,
        onSuccess: (result) {
          userProfileModel.value = result;
          debugPrint("User Name: ${userProfileModel.value?.data?.name}");
        },
      );
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> getProviderProfile() async {
    debugPrint('-->Token in profile: ${AppStorage.token}');
    try {
      await ApiRequest.get<ProviderProfileModels>(
        fromJson: ProviderProfileModels.fromJson,
        endPoint: ApiEndPoints.providerProfile,
        isLoading: isLoading,
        onSuccess: (result) {
          providerProfileModel.value = result;

          final serverValue = result.data.isOnline;

          if (serverValue != null) {
            isOnline.value = serverValue;
          }
        },
      );
    } catch (e) {
      debugPrint("Error fetching provider profile: $e");
    }
  }

  //-------------------
  //-------------------
  //------------------
  RxBool isOnline = false.obs;
  RxBool isToggleLoading = false.obs;

  Future<void> toggleOnlineStatus(bool value) async {
    final oldValue = isOnline.value;

    // optimistic update
    isOnline.value = value;

    try {
      await ApiRequest.patch(
        fromJson: ToggleOnlineResponse.fromJson,
        endPoint: 'provider/toggle-online',

        body: {"isOnline": value.toString()},

        isLoading: isToggleLoading,

        showSuccessSnackBar: false,

        onSuccess: (response) {
          final serverValue = response.data?.isOnline;

          // ✅ sync local state with server (source of truth)
          if (serverValue != null) {
            isOnline.value = serverValue;
          }

          SuccessDialog.show(
            title: "Success",
            subtitle: response.message ?? '',
            onTap: () {
              Get.back();
            },
          );

          HomeVendorController.to.selectedStatus.value = 0;
          HomeVendorController.to.fetch("PENDING", 1);
        },
      );
    } catch (e) {
      // rollback if failed
      isOnline.value = oldValue;

      debugPrint('🔴 Toggle Error: $e');
    }
  }
}

class ToggleOnlineResponse {
  final int? statusCode;
  final bool? success;
  final String? message;
  final ToggleOnlineData? data;

  ToggleOnlineResponse({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  factory ToggleOnlineResponse.fromJson(Map<String, dynamic> json) {
    return ToggleOnlineResponse(
      statusCode: json["statusCode"],
      success: json["success"],
      message: json["message"],
      data: json["data"] != null
          ? ToggleOnlineData.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class ToggleOnlineData {
  final bool? isOnline;
  final DateTime? lastOnlineAt;

  ToggleOnlineData({this.isOnline, this.lastOnlineAt});

  factory ToggleOnlineData.fromJson(Map<String, dynamic> json) {
    return ToggleOnlineData(
      isOnline: json["isOnline"],
      lastOnlineAt: json["lastOnlineAt"] != null
          ? DateTime.parse(json["lastOnlineAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isOnline": isOnline,
      "lastOnlineAt": lastOnlineAt?.toIso8601String(),
    };
  }
}
