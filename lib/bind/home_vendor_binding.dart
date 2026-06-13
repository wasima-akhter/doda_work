import 'package:get/get.dart';

import '../views/home_vendor/controller/home_vendor_controller.dart';

class HomeVendorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeVendorController>(
      () => HomeVendorController(),
      fenix: true,
    );
  }
}
