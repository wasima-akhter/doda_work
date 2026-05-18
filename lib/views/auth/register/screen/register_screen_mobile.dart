part of 'register_screen.dart';

class RegisterScreenMobile extends GetView<RegisterController> {
  const RegisterScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(isBack: false, title: ''),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Space.height.v10,
            TextWidget(
              'Sign Up',
              fontSize: Dimensions.titleLarge,
              fontWeight: FontWeight.bold,
            ),
            TextWidget(
              "Let's get you set up and ready to go.",
              color: CustomColors.primary,
              fontWeight: FontWeight.w500,
            ),
            FieldsSectionView(),
            ButtonAndTextSectionView(),
            Space.height.v10,
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextWidget(
                  // padding: Dimensions.widthSize.edgeLeft,
                  'Already have an account?',
                  color: CustomColors.secondaryDarkText,
                  fontWeight: FontWeight.w400,
                  fontSize: Dimensions.titleMedium * 0.96,
                ),
                TextWidget(
                  padding: Dimensions.widthSize.edgeLeft * 0.24,
                  'Sign In',
                  onTap: () {
                    Get.offAllNamed(Routes.loginScreen);
                  },
                  color: CustomColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: Dimensions.titleMedium * 0.96,
                ),
              ],
            ),
            Space.height.v40,
          ],
        ),
      ),
    );
  }
}
