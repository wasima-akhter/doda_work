import 'package:doda_work/core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../../../widgets/notification_icon.dart';
import '../controller/category_controller.dart';

part 'category_screen_mobile.dart';

class CategoryScreen extends GetView<CategoryController> {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: CategoryScreenMobile());
  }
}
