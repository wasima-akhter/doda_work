part of 'forgot_screen.dart';

class ForgotScreenMobile extends GetView<ForgotController> {
  const ForgotScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Forgot Password'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            TextWidget(
              textAlign: TextAlign.center,
              padding: EdgeInsetsGeometry.only(
                top: Dimensions.heightSize,
                bottom: Dimensions.verticalSize,
              ),
              'Enter your email and we will send you a verification code',
              color: CustomColors.secondaryDarkText,
            ),
            TextWidget(
              textAlign: TextAlign.center,
              padding: EdgeInsetsGeometry.only(bottom: Dimensions.heightSize),
              'Forgot Password?',
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.titleLarge * 0.95,
            ),

            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  PrimaryInputFieldWidget(
                    label: "Email",
                    isEmail: true,
                    controller: controller.emailController,
                    focusNode: controller.emailFocus,
                    hintText: "Enter your email",
                  ),
                  Space.height.betweenInputBox,
                  Space.height.betweenInputBox,

                  Obx(
                    () => PrimaryButtonWidget(
                      title: "Send Code",
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.forgotPasswordProcess();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
