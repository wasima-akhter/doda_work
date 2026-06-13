import 'package:doda_work/core/api/model/basic_success_model.dart';
import 'package:doda_work/core/api/services/api.dart';
import 'package:doda_work/core/utils/app_storage.dart';
import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/routes/routes.dart';

class SettingController extends GetxController {
  RxBool isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearForm() {
    emailController.text = '';
    passwordController.text = '';
  }

  Future<BasicSuccessModel> deleteUserAccount({
    required String email,
    required String password,
  }) async {
    return await ApiRequest.delete(
      fromJson: BasicSuccessModel.fromJson,
      endPoint: ApiEndPoints.deleteProfile,
      isLoading: isLoading,
      showSuccessSnackBar: true,
      body: {"email": email, "password": password},
      onSuccess: (result) {
        Get.back();
        AppStorage.clear();
        Get.offAllNamed(Routes.welcomeScreen);
      },
    );
  }
}
