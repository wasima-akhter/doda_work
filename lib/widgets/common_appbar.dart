import '../core/utils/basic_import.dart';
import 'notification_icon.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? left;
  final Widget? right;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const CommonAppbar({
    super.key,
    required this.title,
    this.left,
    this.right,
    this.height,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      toolbarHeight: Dimensions.appBarHeight * 2.25,
      flexibleSpace: SafeArea(
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
              ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// LEFT
              Align(alignment: Alignment.centerLeft, child: AppBarLogoWidget()),

              /// CENTER (perfectly centered)
              Center(
                child: TextWidget(
                  title,
                  color: CustomColors.blackColor,
                  fontSize: Dimensions.titleMedium * 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// RIGHT
              Align(
                alignment: Alignment.centerRight,
                child: NotificationIcon(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Dimensions.appBarHeight * 2.25);
}
