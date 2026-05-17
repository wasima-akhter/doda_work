import '../../core/utils/app_storage.dart';
import '../../core/utils/basic_import.dart';
import '../../views/profile/controller/profile_controller.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final pctrl = Get.find<ProfileController>();
        final isVendor = AppStorage.isProvider;

        final userName = isVendor
            ? pctrl.providerProfileModel.value?.data.companyName ?? 'Provider'
            : pctrl.userProfileModel.value?.data?.name ?? 'User';

        return Container(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.horizontalSize),
          child: Column(
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
          ),
        );
      },
    );
  }
}
