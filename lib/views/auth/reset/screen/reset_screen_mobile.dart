part of 'reset_screen.dart';

class ResetScreenMobile extends GetView<ResetController> {
  const ResetScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Reset Password'),

      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Space.height.betweenInputBox,
            Space.height.betweenInputBox,
            PrimaryInputFieldWidget(
              hintText: "Enter your password",
              label: "Password",
              isPassword: true,
              controller: controller.passwordController,
              focusNode: controller.passwordFocus,
              nextFocusNode: controller.confirmPasswordFocus,
            ),

            Space.height.betweenInputBox,
            PrimaryInputFieldWidget(
              hintText: "Confirm your password",
              label: "Confirm Password",
              isPassword: true,
              controller: controller.passConfirmController,
              focusNode: controller.confirmPasswordFocus,
              nextFocusNode: null,
              confirmWith: controller.passwordController,
            ),
            Space.height.betweenInputBox,
            Space.height.betweenInputBox,
            Obx(
              () => PrimaryButtonWidget(
                isLoading: controller.isLoading.value,
                title: "Reset Password",
                onPressed: () {
                  controller.resetPasswordService();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
