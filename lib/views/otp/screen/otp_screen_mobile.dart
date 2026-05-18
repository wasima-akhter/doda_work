part of 'otp_screen.dart';

class OtpScreenMobile extends GetView<OtpController> {
  const OtpScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Verification'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Space.height.v30,
            TextWidget(
              textAlign: TextAlign.center,
              padding: EdgeInsetsGeometry.only(bottom: Dimensions.heightSize),
              'Verify Your Account',
              fontWeight: FontWeight.bold,
              fontSize: Dimensions.titleLarge * 0.95,
            ),
            TextWidget(
              textAlign: TextAlign.center,
              padding: EdgeInsetsGeometry.only(
                top: Dimensions.heightSize,
                bottom: Dimensions.verticalSize,
              ),
              "We've sent a verification code to your ${Get.find<ForgotController>().emailController.text} email/phone. Please check and enter it below.",
              color: CustomColors.secondaryDarkText,
            ),
            PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              controller: controller.otpController,
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: (v) {
                debugPrint("Completed");
              },
              beforeTextPaste: (text) {
                debugPrint("Allowing to paste $text");
                return true;
              },
              textStyle: TextStyle(
                color: CustomColors.primary,
                fontSize: Dimensions.titleMedium,
                fontWeight: FontWeight.w500,
              ),
              pinTheme: PinTheme(
                selectedFillColor: CustomColors.whiteColor,
                // ✅ box fill always white
                inactiveFillColor: CustomColors.whiteColor,
                // ✅ box fill always white
                activeFillColor: CustomColors.whiteColor,
                // ✅ box fill always white
                inactiveColor: CustomColors.secondaryDarkText,
                selectedColor: CustomColors.primary,
                activeColor: CustomColors.primary,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
                fieldHeight: 40.h,
                fieldWidth: 40.w,
              ),
            ),

            Row(
              mainAxisAlignment: mainCenter,
              children: [
                TimerWidget(
                  onResendCode: () {
                    controller.resendOtpProcess();
                  },
                ),
              ],
            ),

            Space.height.betweenInputBox,
            Obx(
              () => PrimaryButtonWidget(
                isLoading: controller.isLoading.value,
                title: "Verify Code",
                // onPressed: () {},
                onPressed: () => controller.emailVerifyProcess(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
