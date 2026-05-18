part of 'change_password_screen.dart';

class ChangePasswordScreenMobile extends GetView<ChangePasswordController> {
  const ChangePasswordScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Change Password'),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
            children: [
              Space.height.betweenInputBox,
              PrimaryInputFieldWidget(
                hintText: "Type your password",
                label: "Type Password",
                isPassword: true,
                controller: controller.oldPasswordController,
                focusNode: controller.isOldPasswordFocus,
                nextFocusNode: controller.passwordFocus,
              ),
              Space.height.betweenInputBox,
              PrimaryInputFieldWidget(
                hintText: "Enter New password",
                label: "New Password",
                isPassword: true,
                controller: controller.passwordController,
                focusNode: controller.passwordFocus,
                nextFocusNode: controller.confirmPasswordFocus,
              ),
              Space.height.betweenInputBox,
              PrimaryInputFieldWidget(
                hintText: "Confirm password",
                label: "Confirm Password",
                isPassword: true,
                controller: controller.passConfirmController,
                focusNode: controller.confirmPasswordFocus,
                nextFocusNode: null,
                confirmWith:
                    controller.passwordController, // only checks matching
              ),
              Space.height.betweenInputBox,
              Space.height.betweenInputBox,
              Obx(
                () => PrimaryButtonWidget(
                  title: 'Update',
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.changePasswordProcess();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
