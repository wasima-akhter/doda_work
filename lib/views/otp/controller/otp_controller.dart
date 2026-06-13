import 'package:doda_work/views/auth/forgot/controller/forgot_controller.dart';

import '../../../core/api/services/auths.dart';
import '../../../core/utils/basic_import.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();
  RxBool isLoading = false.obs;

  emailVerifyProcess() async {
    return await AuthService.otpVerifyService(
      isLoading: isLoading,
      email: Get.find<ForgotController>().emailController.text,
      activationCode: otpController.text,
    );
  }

  RxBool isLoadingResend = false.obs;

  resendOtpProcess() async {
    return await AuthService.resendOtpService(
      isLoading: isLoadingResend,
      email: Get.find<ForgotController>().emailController.text,
    );
  }
}
