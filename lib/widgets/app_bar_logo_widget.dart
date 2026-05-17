import '../core/utils/basic_import.dart';
import '../views/navigation/controller/navigation_controller.dart';

class AppBarLogoWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBarLogoWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.find<NavigationController>().goToProfile(),
      child: Image.asset(
        Assets.logo.aaplogo.path,
        height: 90.w,
        width: 90.w,
        fit: BoxFit.cover,
      ),
    );
  }
}
