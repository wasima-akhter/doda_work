import 'package:doda_work/core/api/services/auths.dart';

import '../../../../core/utils/basic_import.dart';

// class VerifyController extends GetxController {
//   final otpController = TextEditingController();

//   RxBool isLoading = false.obs;
//   RxBool isLoadingResend = false.obs;

//   emailVerifyProcess() async {
//     return await AuthService.emailVerifyService(
//       isLoading: isLoading,
//       email: Get.find<RegisterController>().emailController.text,
//       activationCode: otpController.text,
//     );
//   }

//   resendOtpProcess() async {
//     return await AuthService.resendOtpService(
//       isLoading: isLoadingResend,
//       email: Get.find<RegisterController>().emailController.text,
//     );
//   }
// }

class VerifyController extends GetxController {
  final otpController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isLoadingResend = false.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    email = args["email"] ?? "";
  }

  emailVerifyProcess() async {
    return await AuthService.emailVerifyService(
      isLoading: isLoading,
      email: email,
      activationCode: otpController.text,
    );
  }

  resendOtpProcess() async {
    return await AuthService.resendOtpService(
      isLoading: isLoadingResend,
      email: email,
    );
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
