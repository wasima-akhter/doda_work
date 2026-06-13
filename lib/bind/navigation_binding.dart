import 'package:doda_work/views/category/controller/category_controller.dart';
import 'package:doda_work/views/home/controller/home_controller.dart';
import 'package:doda_work/views/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

import '../views/home_vendor/controller/home_vendor_controller.dart';
import '../views/navigation/controller/navigation_controller.dart';
import '../views/request/controller/request_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestController>(() => RequestController());
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<HomeVendorController>(
      () => HomeVendorController(),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.put(CategoryController(), permanent: true);
  }
}
