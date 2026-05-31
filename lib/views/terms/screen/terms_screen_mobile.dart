import 'package:doda_work/views/terms/controller/terms_controller.dart'; // Ensure the correct path is used
import 'package:doda_work/widgets/auth_app_bar.dart';
import 'package:doda_work/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/simple_webview_widget.dart';

class TermsScreenMobile extends GetView<TermsController> {
  const TermsScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getTermsCondition();
    return Scaffold(
      appBar: AuthAppBar(title: 'Terms & Conditions'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: LoadingWidget());
          }

          if (controller.termsData.value.data?.description != null) {
            final description =
                controller.termsData.value.data?.description ?? "";
            return SimpleWebViewWidget(htmlContent: description);

            /*
            return ListView(
              padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Html(
                    data: controller.termsData.value.data?.description ?? "",
                    style: {
                      "h1": Style(
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      "u": Style(textDecoration: TextDecoration.underline),
                    },
                  ),
                ),
              ],
            );

         */
          }

          return Center(child: Text('No terms available.'));
        }),
      ),
    );
  }
}
