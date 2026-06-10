import 'package:doda_work/core/utils/extensions.dart';
import 'package:doda_work/routes/routes.dart';
import 'package:doda_work/widgets/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadify/shadify.dart';
import '../../../core/themes/token.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/layout.dart';
import '../../../core/utils/space.dart';
import '../../../widgets/text_widget.dart';
import '../controller/document_controller.dart';

part 'document_screen_mobile.dart';

class DocumentScreen extends GetView<DocumentController> {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(mobile: DocumentScreenMobile());
  }
}
