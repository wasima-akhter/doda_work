part of '../screen/profile_screen.dart';

class ProfileCardSectionWidgetView extends GetView<ProfileController> {
  ProfileCardSectionWidgetView({super.key});

  final LoginController logoutController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        _buildSectionCard(
          Icons.settings,
          'Account Settings ',
          () => Get.toNamed(Routes.settingScreen),
        ),

        if (AppStorage.users == 'PROVIDER')
          _buildSectionCard(
            Icons.reviews_outlined,
            'Reviews & Ratings',
            isVisible: AppStorage.isVendor,
            () => Get.toNamed(Routes.reviewRatingScreen),
          ),

        _buildSectionCard(
          Icons.dataset_outlined,
          'Documents',
          isVisible: AppStorage.isVendor,

          () => Get.toNamed(Routes.documentScreen),
        ),
        _buildSectionCard(
          Icons.favorite_border,
          'Favorites',
          isVisible: AppStorage.isVendor == false,
          () => Get.toNamed(Routes.favoriteScreen),
        ),
        _buildSectionCard(
          Icons.help_outline_sharp,
          'FAQs',
          isVisible: AppStorage.isVendor == false,

          () => Get.toNamed(Routes.faqScreen),
        ),
        _buildSectionCard(
          Icons.notification_add_outlined,
          'Notifications',
          () => Get.toNamed(Routes.notificationScreen),
        ),

        TextWidget(
          'More',
          fontWeight: FontWeight.w500,
          padding: Dimensions.heightSize.edgeTop,
        ),
        10.verticalSpace,

        _buildSectionCard(
          Icons.menu_book_outlined,
          'Terms and Conditions',
          () => Get.toNamed(Routes.termsScreen),
        ),
        _buildSectionCard(
          Icons.my_library_books_outlined,
          'Privacy policy',
          () => Get.toNamed(Routes.privacyScreen),
        ),
        _buildSectionCard(Icons.logout, 'Log Out', () {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
              ),
              title: TextWidget(
                'Logout',
                fontSize: Dimensions.titleLarge,
                fontWeight: FontWeight.w500,
              ),
              content: const TextWidget('Are you sure you want to log out?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(
                        Dimensions.radius * 0.8,
                      ),
                    ),
                  ),
                  child: TextWidget('No', color: CustomColors.whiteColor),
                ),

                ElevatedButton(
                  onPressed: () {
                    logoutController.signOutGoogle();
                    logoutController.signOutApple();
                    AppStorage.clear();
                    Get.offAllNamed(Routes.welcomeScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: CustomColors.rejected),
                      borderRadius: BorderRadiusGeometry.circular(
                        Dimensions.radius * 0.8,
                      ),
                    ),
                  ),
                  child: TextWidget('Yes', color: CustomColors.rejected),
                ),
              ],
            ),
            barrierDismissible: true,
          );
        }),
      ],
    );
  }

  _buildSectionCard(
    IconData icon,
    String title,
    void Function()? onTap, {
    bool isVisible = true,
  }) {
    if (!isVisible) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: Dimensions.heightSize.edgeBottom,
        child: Obx(
          () => Container(
            // height: Dimensions.heightSize * 4.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
              border: Border.all(color: Colors.grey.withAlpha(555)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: mainSpaceBet,
              children: [
                Wrap(
                  spacing: Dimensions.defaultHorizontalSize * 0.2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      onPressed: null,
                      icon: Icon(icon, color: CustomColors.primary),
                    ),
                    TextWidget(title, fontSize: Dimensions.titleSmall * 1.1),
                  ],
                ),
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: CustomColors.primary,
                  ),
                ),
              ],
            ),
          ).withShadifyLoading(loading: controller.isLoading.value),
        ),
      ),
    );
  }
}
