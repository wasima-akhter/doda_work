import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/basic_import.dart';

class SimpleWebViewWidget extends StatelessWidget {
  final String htmlContent;
  final double? height;
  final double? fontSize;
  final Color backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;

  const SimpleWebViewWidget({
    super.key,
    required this.htmlContent,
    this.height,
    this.fontSize,
    this.backgroundColor = Colors.transparent,
    this.textColor,
    this.padding = EdgeInsets.zero,
  });

  String _toCssColor(Color color) {
    if (color == Colors.transparent) return 'transparent';
    return 'rgba(${color.red},${color.green},${color.blue},${color.opacity})';
  }

  String get _paddingCss =>
      '${padding.top}px ${padding.right}px ${padding.bottom}px ${padding.left}px';

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(backgroundColor)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (request.url == 'about:blank') {
              return NavigationDecision.navigate;
            }

            final uri = Uri.tryParse(request.url);

            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString("""
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body {
  margin: 0;
  padding: $_paddingCss;
  background: ${_toCssColor(backgroundColor)};
  font-family: 'Outfit', sans-serif;
  font-size: ${fontSize ?? 14}px;
  color: ${_toCssColor(textColor ?? Colors.black87)};
}

* {
  max-width: 100%;
  box-sizing: border-box;
}

img, iframe, table, video {
  max-width: 100% !important;
  height: auto !important;
}

a {
  color: blue;
  text-decoration: underline;
}
</style>
</head>
<body>
$htmlContent
</body>
</html>
""");

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: WebViewWidget(controller: controller),
    );
  }
}
