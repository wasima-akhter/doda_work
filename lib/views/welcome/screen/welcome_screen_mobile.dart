part of 'welcome_screen.dart';

class WelcomeScreenMobile extends GetView<WelcomeController> {
  const WelcomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('+++++++++++++++++++++++++++++++++++++++++++++++++++');
    debugPrint('+++++++++++++++++++++++++++++++++++++++++++++++++++');
    debugPrint('+++++++++++++++++++++++++++++++++++++++++++++++++++');
    debugPrint(AppStorage.users);
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showSearch: false,
                    useSafeArea: true,
                    countryListTheme: CountryListThemeData(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius * 0.8,
                      ),
                      backgroundColor: CustomColors.whiteColor,
                      bottomSheetHeight:
                          MediaQuery.of(context).size.height * 0.5,
                      textStyle: TextStyle(color: CustomColors.blackColor),
                    ),
                    onSelect: (Country country) {
                      controller.selectedCountry.value = country.name;
                      controller.selectedCountryFlag.value = country.flagEmoji;
                      debugPrint(controller.selectedCountry.value);
                      debugPrint(controller.selectedCountryFlag.value);
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsetsGeometry.only(
                    top: Dimensions.verticalSize * 2,
                    bottom: Dimensions.heightSize,
                  ),
                  padding: Dimensions.widthSize.edgeHorizontal,
                  height: Dimensions.buttonHeight * 0.7,
                  decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radius),
                  ),
                  child: Row(
                    mainAxisSize: mainMin,
                    mainAxisAlignment: mainSpaceBet,
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            controller.selectedCountryFlag.value,
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),

                      Obx(
                        () => TextWidget(
                          controller.selectedCountry.value,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: Dimensions.widthSize,
                          ),
                          color: CustomColors.whiteColor,
                          fontSize: Dimensions.labelLarge * 1.2,
                        ),
                      ),

                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: Dimensions.iconSizeLarge,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              // TextWidget(
              //   "Join Us",
              //   // onTap: () => Get.toNamed(Routes.registerScreen),
              //   color: CustomColors.primary,
              //   fontSize: Dimensions.titleLarge * 0.9,
              // ),
              GestureDetector(
                onTap: () {
                  AppStorage.save(isUsers: 'USER');
                  Get.toNamed(Routes.loginScreen);
                },

                child: AnimatedContainer(
                  margin: EdgeInsetsGeometry.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize,
                    vertical: Dimensions.verticalSize * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.whiteColor,
                    border: Border.all(color: CustomColors.primary, width: 1.8),
                    borderRadius: BorderRadius.circular(Dimensions.radius * 3),
                  ),
                  height: Dimensions.buttonHeight * 0.7,
                  width: double.infinity,

                  duration: const Duration(milliseconds: 300),

                  child: Row(
                    mainAxisAlignment: mainCenter,
                    children: [
                      Icon(
                        Icons.person,
                        size: Dimensions.iconSizeLarge,
                        color: CustomColors.primary,
                      ),
                      TextWidget(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: Dimensions.widthSize,
                        ),
                        'As a Client',
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.titleMedium * 1.2,
                        color: CustomColors.primary,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: CustomColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Get.offAllNamed(Routes.loginScreen);
                  AppStorage.save(isUsers: 'PROVIDER');
                  debugPrint(AppStorage.users);
                },
                child: AnimatedContainer(
                  margin: EdgeInsetsGeometry.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.primary,
                    border: Border.all(color: CustomColors.primary, width: 1.8),
                    borderRadius: BorderRadius.circular(Dimensions.radius * 3),
                  ),
                  height: Dimensions.buttonHeight * 0.7,
                  width: double.infinity,

                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisAlignment: mainCenter,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.request1,
                        colorFilter: ColorFilter.mode(
                          CustomColors.whiteColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      TextWidget(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: Dimensions.widthSize,
                        ),
                        'As a Service Provider',
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.titleMedium * 1.2,
                        color: CustomColors.whiteColor,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: CustomColors.whiteColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AuthAppBar(title: '', isBack: false),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextWidget(
                  'Welcome to ',
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.titleLarge,
                ),
                TextWidget(
                  'dodawork!',
                  color: CustomColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: Dimensions.titleLarge,
                ),
                Space.height.v40,
                Space.height.v40,
              ],
            ),
            Space.height.v40,
            SvgPicture.asset(Assets.dummy.mobileLoginRafiki1),
          ],
        ),
      ),
    );
  }
}
