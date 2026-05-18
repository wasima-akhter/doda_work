// web_payment_stub.dart  ← stub for web/unsupported platforms

import 'package:flutter/material.dart';

import 'loading_widget.dart';

// Stub when webview_flutter is unavailable (e.g., Flutter Web)
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
  @override
  void initState() {
    super.initState();
    // Immediately fallback on unsupported platforms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFallback();
    });
  }

  @override
  Widget build(BuildContext context) => const LoadingWidget();
}
