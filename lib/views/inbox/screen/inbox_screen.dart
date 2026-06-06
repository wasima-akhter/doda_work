import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/layout.dart';
import '../controller/inbox_controller.dart';
import 'inbox_screen_mobile.dart';

class InboxScreen extends GetView<InboxController> {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: InboxScreenMobile());
  }
}
