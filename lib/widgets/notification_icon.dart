import '../core/utils/basic_import.dart';
import '../routes/routes.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.notificationScreen),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: CustomColors.primary),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(Assets.icons.group),
      ),
    );
  }
}
