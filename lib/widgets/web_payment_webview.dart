// web_payment_webview.dart  ← real implementation (mobile)

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'loading_widget.dart';

class WebPaymentView extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onSuccess;
  final void Function(String message) onFailure;
  final VoidCallback onFallback;
  final void Function(bool loading) onLoadingChanged;
  final bool isLoading;

  const WebPaymentView({
    super.key,
    required this.paymentUrl,
    required this.onSuccess,
    required this.onFailure,
    required this.onFallback,
    required this.onLoadingChanged,
    required this.isLoading,
  });

  @override
  State<WebPaymentView> createState() => _WebPaymentViewState();
}

class _WebPaymentViewState extends State<WebPaymentView> {
  WebViewController? _webViewController;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => widget.onLoadingChanged(true),
            onPageFinished: (String url) {
              widget.onLoadingChanged(false);
              debugPrint("✅ Current URL: $url");
              _checkUrl(url);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("❌ WebView Error: ${error.description}");

              // Only fatal errors should trigger fallback
              // Ignore sub-resource errors (fonts, analytics, etc.)
              if (_isFatalError(error)) {
                widget.onFallback();
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Allow Stripe and related domains
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      debugPrint("❌ WebView init error: $e");
      // WebView couldn't initialize at all (e.g., emulator GPU issue)
      setState(() => _initFailed = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFallback();
      });
    }
  }

  bool _isFatalError(WebResourceError error) {
    // Only trigger fallback for main frame fatal errors
    // Ignore sub-resource errors (error.isForMainFrame may be available)
    final fatalDescriptions = [
      'net::ERR_CONNECTION_REFUSED',
      'net::ERR_NAME_NOT_RESOLVED',
      'net::ERR_INTERNET_DISCONNECTED',
    ];
    return fatalDescriptions.any((desc) => error.description.contains(desc));
  }

  void _checkUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('success') || lower.contains('payment_success')) {
      widget.onSuccess();
    } else if (lower.contains('cancel') ||
        lower.contains('failed') ||
        lower.contains('payment_failed')) {
      widget.onFailure("Payment failed or was cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed || _webViewController == null) {
      return const LoadingWidget(); // onFallback already called
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        if (widget.isLoading) const Positioned.fill(child: LoadingWidget()),
      ],
    );
  }
}
