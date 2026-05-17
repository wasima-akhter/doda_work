import '../../../core/utils/basic_import.dart';
import '../../../widgets/notification_icon.dart';
import '../../profile/controller/profile_controller.dart';

class HomeAppBarWidgetView extends GetView<ProfileController> {
  const HomeAppBarWidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LOGO
            AppBarLogoWidget(),

            Space.width.v10,
            /*
            /// DIVIDER
            Container(
              height: 36.h,
              width: 1.5.w,
              color: CustomColors.disableColor.withAlpha(120),
            ),

            Space.width.v15,

            /// USER GREETING

            Expanded(
              child: Obx(() {
                final isVendor = AppStorage.isProvider;

                final userName = isVendor
                    ? controller.providerProfileModel.value?.data.companyName ??
                          'Provider'
                    : controller.userProfileModel.value?.data?.name ?? 'User';

                return Column(
                  crossAxisAlignment: crossStart,
                  mainAxisAlignment: mainCenter,
                  mainAxisSize: mainMin,
                  children: [
                    Row(
                      children: [
                        TextWidget(
                          "Hello, ",
                          fontSize: Dimensions.bodyMedium,
                          color: CustomColors.secondaryDarkText,
                          fontWeight: FontWeight.w400,
                        ),
                        Flexible(
                          child: TextWidget(
                            userName,
                            fontSize: Dimensions.bodyMedium,
                            fontWeight: FontWeight.w700,
                            color: CustomColors.blackColor,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Space.height.v5,
                    TextWidget(
                      'Welcome Back 👋',
                      fontSize: Dimensions.labelMedium,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.primary,
                    ),
                  ],
                );
              }),
            ),
*/
            /// NOTIFICATION ICON
            NotificationIcon(),
          ],
        ),
      ),
    );
  }
}
