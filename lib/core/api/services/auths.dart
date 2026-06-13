import 'package:doda_work/core/api/model/basic_success_model.dart';
import 'package:doda_work/core/utils/message_helper.dart';
import 'package:doda_work/widgets/success_dialog.dart';

import '../../../routes/routes.dart';
import '../../../views/auth/login/model/login_model.dart';
import '../../../views/auth/register/model/provider_otp_verify_model.dart';
import '../../utils/app_storage.dart';
import '../../utils/basic_import.dart';
import 'api.dart';

class OtpRequiredException implements Exception {
  final String message;
  final String email;

  OtpRequiredException(this.message, this.email);
}

class AuthService {
  /// =============================================== ✅ Login  ================================================== ///
  /*
  static Future<LoginModel> loginService({
    required RxBool isLoading,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    Map<String, dynamic> inputBody = {'email': email, 'password': password};
    return await ApiRequest.post(
      fromJson: LoginModel.fromJson,
      endPoint: ApiEndPoints.login,
      isLoading: isLoading,
      body: inputBody,

      onSuccess: (result) async {
        final role = result.data.user.authId.role.toUpperCase();
        final id = result.data.user.id;

        final selectedRole = AppStorage.users.toUpperCase();

        if (role != selectedRole) {
          MessageHelper.showError(
            "This account is registered as a ${role == 'PROVIDER' ? 'Service Provider' : 'Client'}.\nPlease use the correct login option.",
          );
          return;
        }

        await AppStorage.save(uId: id);
        await AppStorage.save(token: result.data.accessToken, isLoggedIn: true);
        await AppStorage.saveRole(role);
        AppStorage.isVendor = role == "PROVIDER";

        if (rememberMe) {
          AppStorage.rememberMe = true;
          AppStorage.savedEmail = email;
          AppStorage.savedPassword = password;
        } else {
          AppStorage.rememberMe = false;
          AppStorage.savedEmail = '';
          AppStorage.savedPassword = '';
        }

        if (role == "PROVIDER" || role == "USER") {
          Get.offAllNamed(Routes.navigationScreen);
        } else {
          MessageHelper.showError("Please Select Your Role.\nThank you");
        }
      },
    );
  }
*/
  static Future<LoginModel> loginService({
    required RxBool isLoading,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      return await ApiRequest.post(
        fromJson: LoginModel.fromJson,
        endPoint: ApiEndPoints.login,
        isLoading: isLoading,
        body: {'email': email, 'password': password},

        onSuccess: (result) async {
          // existing success logic (UNCHANGED)

          final role = result.data.user.authId.role.toUpperCase();
          final id = result.data.user.id;

          final selectedRole = AppStorage.users.toUpperCase();

          if (role != selectedRole) {
            MessageHelper.showError(
              "This account is registered as a ${role == 'PROVIDER' ? 'Service Provider' : 'Client'}.\nPlease use the correct login option.",
            );
            return;
          }

          await AppStorage.save(uId: id);
          await AppStorage.save(
            token: result.data.accessToken,
            isLoggedIn: true,
          );
          await AppStorage.saveRole(role);
          AppStorage.isVendor = role == "PROVIDER";

          if (rememberMe) {
            AppStorage.rememberMe = true;
            AppStorage.savedEmail = email;
            AppStorage.savedPassword = password;
          }

          if (role == "PROVIDER" || role == "USER") {
            Get.offAllNamed(Routes.navigationScreen);
          }
        },
      );
    } on OtpRequiredException catch (e) {
      // ============================
      // 🔥 OTP FLOW HERE
      // ============================

      await AuthService.resendOtpService(isLoading: isLoading, email: e.email);

      Get.toNamed(Routes.verifyScreen, arguments: {"email": email});

      rethrow;
    }
  }

  /// =============================================== ✅ Register  ================================================== ///

  static Future<BasicSuccessModel> registerService({
    required RxBool isLoading,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String confirmPassword,
  }) async {
    Map<String, dynamic> inputBody = {
      'email': email,
      'role': role,
      'phoneNumber': phone,
      'name': name,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    return await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.register,
      isLoading: isLoading,
      body: inputBody,
      onSuccess: (result) {
        Get.toNamed(Routes.verifyScreen, arguments: {"email": email});

        AppStorage.savedName = name;
      },
    );
  }

  /// =============================================== ✅ Forget Password ================================================== ///

  static Future<BasicSuccessModel> forgotPasswordService({
    required RxBool isLoading,
    required String email,
  }) async {
    Map<String, dynamic> inputBody = {'email': email};
    return await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.forgotPassword,
      isLoading: isLoading,
      body: inputBody,
      onSuccess: (result) => Get.toNamed(
        Routes.otpScreen,
        arguments: {"email": email, "type": "forgot"},
      ),
    );
  }

  /// =============================================== ✅ Email Verify  ================================================== ///

  static Future<ProviderOtpVerify> emailVerifyService({
    required RxBool isLoading,
    required String email,
    required String activationCode,
  }) async {
    Map<String, dynamic> inputBody = {
      'activationCode': activationCode,
      'email': email,
    };
    return await ApiRequest.post(
      fromJson: ProviderOtpVerify.fromJson,
      endPoint: ApiEndPoints.verifyEmail,
      isLoading: isLoading,
      body: inputBody,
      onSuccess: (result) {
        if (AppStorage.users == "PROVIDER") {
          // Get.toNamed(Routes.aditionalScreen);
          Get.offAllNamed(Routes.aditionalScreen);
        } else {
          SuccessDialog.show(
            title: "Registration Successful",
            subtitle:
                "Your account has been created successfully. Please login to continue.",
            onTap: () => Get.offAllNamed(Routes.loginScreen),
          );
        }

        // AppStorage.isVendor == true
        //     ? Get.toNamed(Routes.aditionalScreen)
        //     : Get.offAllNamed(Routes.loginScreen);

        AppStorage.save(token: result.data.accessToken);
      },
    );
  }

  /// =============================================== ✅ Otp Verify  ================================================== ///

  static Future<BasicSuccessModel> otpVerifyService({
    required RxBool isLoading,
    required String email,
    required String activationCode,
  }) async {
    Map<String, dynamic> inputBody = {'code': activationCode, 'email': email};
    return await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.forgotOtpVerify,
      isLoading: isLoading,
      body: inputBody,
      onSuccess: (result) {
        // if (AppStorage.users == "PROVIDER") {
        //   Get.toNamed(Routes.aditionalScreen);
        // } else {
        //   SuccessDialog.show(
        //     title: "Registration Successful",
        //     subtitle: "Your account has been created successfully. Please login to continue.",
        //     onTap: () => Get.offAllNamed(Routes.loginScreen),
        //   );
        // }
        //
        // // AppStorage.isVendor == true
        // //     ? Get.toNamed(Routes.aditionalScreen)
        // //     : Get.offAllNamed(Routes.loginScreen);
        //
        // AppStorage.save(token: result.data.accessToken);

        Get.toNamed(Routes.resetScreen);
      },
    );
  }

  /// =============================================== ✅ Resend Verification ================================================== ///

  static Future<BasicSuccessModel> resendOtpService({
    required RxBool isLoading,
    required String email,
  }) async {
    Map<String, dynamic> inputBody = {'email': email};
    return await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.resendOtpCode,
      isLoading: isLoading,
      body: inputBody,
      showSuccessSnackBar: true,
      onSuccess: (result) {},
    );
  }

  /// =============================================== ✅ Change Password ================================================== ///

  static Future<BasicSuccessModel> changePasswordService({
    required RxBool isLoading,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Map<String, dynamic> inputBody = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
    return await ApiRequest.patch(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.changePassword,
      isLoading: isLoading,
      body: inputBody,
      showSuccessSnackBar: true,
      onSuccess: (result) {
        MessageHelper.showSuccess("Change Password Success");
        Get.back();
        Get.toNamed(Routes.loginScreen);
      },
    );
  }

  static Future<BasicSuccessModel> resetPasswordService({
    required RxBool isLoading,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    Map<String, dynamic> inputBody = {
      'email': email,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
    return await ApiRequest.post(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.resetPassword,
      isLoading: isLoading,
      body: inputBody,

      showSuccessSnackBar: true,
      onSuccess: (result) {
        MessageHelper.showSuccess("Password reset was successful");
        Get.back();
        Get.toNamed(Routes.loginScreen);
      },
    );
  }
}
