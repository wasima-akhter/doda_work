import 'package:doda_work/core/utils/app_storage.dart';
import 'package:doda_work/core/utils/basic_import.dart';
import 'package:doda_work/core/utils/extensions.dart';
import 'package:doda_work/widgets/auth_app_bar.dart';
import '../../../core/helpers/full_screen_image_viewer.dart';
import '../../home/model/home_model.dart';
import '../../request/screen/request_screen.dart';
import '../controller/summary_controller.dart';
import '../model/summary_model.dart';
import '../widget/complete_dialog.dart';

part 'summary_screen_mobile.dart';
part '../widget/buttons_section_widget.dart';
part '../widget/image_header_widget.dart';
part '../widget/request_text_box_widget.dart';

class SummaryScreen extends GetView<SummaryController> {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: SummaryScreenMobile());
  }
}
