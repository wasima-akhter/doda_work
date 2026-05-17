part of 'profile_screen.dart';

class ProfileScreenMobile extends GetView<ProfileController> {
  const ProfileScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimensions.appBarHeight * 2.25,
        scrolledUnderElevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            child: Row(
              mainAxisAlignment: mainSpaceBet,
              children: [
                AppBarLogoWidget(),
                TextWidget(
                  'Profile',
                  color: CustomColors.blackColor,
                  fontSize: Dimensions.titleMedium * 1.2,
                  fontWeight: FontWeight.w600,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => controller.loadProfile(),
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.paddingSize * 0.35),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CustomColors.primary),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: CustomColors.primary,
                          size: Dimensions.iconSizeLarge * 0.8,
                        ),
                      ),
                    ),
                    Space.width.v10,

                    /// NOTIFICATION ICON
                    NotificationIcon(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? LoadingWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadProfile();
                  },
                  color: CustomColors.primary,
                  child: ListView(
                    padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
                    children: [
                      if (AppStorage.users == 'USER')
                        ProfileTopHeaderWidgetView(),
                      if (AppStorage.users == 'PROVIDER')
                        ProfileTopWidgetView(),
                      Space.height.v20,
                      ProfileCardSectionWidgetView(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
