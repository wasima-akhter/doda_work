import 'package:doda_work/widgets/auth_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/utils/basic_import.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _webViewController;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
          },

          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: widget.title),
      body: Obx(
        () => Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (isLoading.value)
              Center(
                child: CircularProgressIndicator(color: CustomColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
