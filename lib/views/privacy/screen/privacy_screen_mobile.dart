part of 'privacy_screen.dart';

class PrivacyScreenMobile extends GetView<PrivacyController> {
  const PrivacyScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AuthAppBar(title: 'Privacy Policy'),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: LoadingWidget());
          }

          if (controller.privacyData.value.data?.description != null) {
            final description =
                controller.privacyData.value.data?.description ?? "";
            return SimpleWebViewWidget(htmlContent: description);
          }

          return Center(child: Text('No terms available.'));
        }),
      ),
    );
  }
}

/*
            return ListView(
              padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Privacy Policy',
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
                    data: controller.privacyData.value.data?.description ?? "",
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
