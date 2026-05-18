part of 'onboard_screen.dart';

class OnboardScreenMobile extends GetView<OnboardController> {
  const OnboardScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          // height: MediaQuery.of(context).size.height * 0.38,
          child: Column(
            mainAxisSize: mainMin,
            mainAxisAlignment: mainSpaceBet,
            children: [
              Wrap(
                children: List.generate(
                  controller.onboardItemList.length,
                  (index) => Obx(
                    () => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin:
                          Dimensions.defaultHorizontalSize.edgeHorizontal *
                          0.35,
                      height: 8,
                      width: controller.currentIndex.value == index
                          ? Dimensions.widthSize * 3
                          : 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius * 2.5,
                        ),
                        color: controller.currentIndex.value == index
                            ? CustomColors.primary
                            : CustomColors.disableColor,
                      ),
                    ),
                  ),
                ),
              ),
              Space.height.v20,
              Column(
                children: [
                  Obx(
                    () => PrimaryButtonWidget(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.defaultHorizontalSize,
                      ),
                      title:
                          controller.currentIndex.value ==
                              controller.onboardItemList.length - 1
                          ? "Continue"
                          : "Next",
                      onPressed: () => controller.next(),
                    ),
                  ),
                  PrimaryButtonWidget(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.defaultHorizontalSize,
                      vertical: Dimensions.verticalSize * 0.5,
                    ),
                    title: 'Join us',
                    outlineButton: true,
                    borderWidth: 1.5,
                    onPressed: () => Get.offAllNamed(Routes.welcomeScreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AuthAppBar(title: '', isSkip: true, isBack: false),
      body: SafeArea(
        child: Padding(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardItemList.length,
            physics: const ClampingScrollPhysics(),
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final item = controller.onboardItemList[index];
              return Column(
                children: [
                  SvgPicture.asset(item.image, fit: BoxFit.cover),
                  TextWidget(
                    item.title,
                    fontSize: Dimensions.titleMedium * 1.2,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primary,
                  ),
                  TextWidget(
                    maxLines: 2,
                    item.subtitle,
                    color: CustomColors.grayShade,
                    textAlign: TextAlign.center,
                    padding: EdgeInsetsGeometry.only(
                      top: Dimensions.heightSize * 0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
