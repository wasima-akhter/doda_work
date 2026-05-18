import 'package:doda_work/routes/routes.dart';

import '../core/utils/basic_import.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;

  // ✅ Optional Color Parameters
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final Color? borderColor;
  final bool isSkip;
  final void Function()? onTap;
  final bool isPrimary;

  const AuthAppBar({
    super.key,
    required this.title,
    this.isBack = true,
    this.isSkip = false,
    this.isPrimary = false,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: isBack
          ? InkWell(
              onTap: onTap ?? () => Get.close(1),
              child: Icon(
                Icons.arrow_back_ios,
                color: isPrimary
                    ? CustomColors.primary
                    : CustomColors.blackColor,
              ),
            )
          : null,
      title: TextWidget(
        title,
        color: isPrimary
            ? titleColor ?? CustomColors.primary
            : CustomColors.blackColor,
        fontSize: Dimensions.titleMedium * 1.2,
        fontWeight: FontWeight.w600,
      ),

      actions: [
        isSkip == true
            ? TextWidget(
                onTap: () => Get.offAllNamed(Routes.welcomeScreen),
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: Dimensions.defaultHorizontalSize,
                ),
                'Skip',
                color: CustomColors.primary,
              )
            : Container(),
      ],
    );
  }
}
