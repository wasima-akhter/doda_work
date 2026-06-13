import 'package:doda_work/core/utils/extensions.dart';
import 'package:doda_work/routes/routes.dart';
import 'package:doda_work/widgets/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/token.dart';
import '../../../core/utils/basic_import.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/layout.dart';
import '../../../core/utils/space.dart';
import '../../../widgets/primary_input_widget.dart';
import '../../../widgets/text_widget.dart';
import '../controller/setting_controller.dart';

part 'setting_screen_mobile.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: SettingScreenMobile());
  }
}
