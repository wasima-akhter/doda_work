import 'dart:io';

import 'package:doda_work/views/home_vendor/controller/home_vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
// Only import webview on Android/iOS — never on other platforms
import 'package:webview_flutter/webview_flutter.dart'
    show
        WebViewController,
        WebViewWidget,
        JavaScriptMode,
        NavigationDelegate,
        NavigationDecision;

import '../../../routes/routes.dart';
import '../../../widgets/custom_snackbar.dart';
import 'auth_app_bar.dart';
import 'loading_widget.dart';

// web_payment_screen.dart

// web_payment_screen.dart
// Single file — no conditional imports needed

class WebPaymentScreen extends StatefulWidget {
  const WebPaymentScreen({super.key});

  @override
  State<WebPaymentScreen> createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends State<WebPaymentScreen> {
  final controller = Get.find<HomeVendorController>();

  WebViewController? _webViewController;
  bool _useWebView = false;
  bool _isLoading = true;
  bool _fallbackReady = false;

  String get _paymentUrl => controller.paymentUrl.value;

  @override
  void initState() {
    super.initState();

    if (_paymentUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleFailure("Payment URL not found");
      });
      return;
    }

    _decideRenderMode();
  }

  //

  /// Key insight: the crash happens because the emulator's GPU driver
  /// doesn't support OpenGL ES 3.1 (EGL_BAD_CONFIG).
  /// We detect this BEFORE creating WebViewController by checking
  /// environment signals that reliably indicate the broken emulator.
  void _decideRenderMode() {
    final canUseWebView = _isWebViewSafe();

    if (canUseWebView) {
      _initWebView();
    } else {
      // Go straight to browser — don't touch WebViewController at all
      setState(() {
        _useWebView = false;
        _fallbackReady = true;
        _isLoading = false;
      });
      // Auto-open browser immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInBrowser();
      });
    }
  }

  /// Checks whether it's safe to instantiate a WebView on this device.
  ///
  /// The crash (EGL_BAD_CONFIG / GFXSTREAM no ES 3.1 support) only occurs on
  /// ARM64 Android emulators (emu64a / emu64a16k) running Android 16+ with
  /// the GFXSTREAM/Mesa GPU stack. Real devices always have proper GPU drivers.
  ///
  /// We cannot catch the crash in Dart — the native thread calls abort().
  /// So we must detect and avoid it proactively.
  bool _isWebViewSafe() {
    if (!Platform.isAndroid) return true; // iOS is always fine

    try {
      // Read Android system properties to detect broken emulator GPU stack.
      // These properties exist on all Android devices but differ between
      // real hardware and the GFXSTREAM emulator that causes the crash.
      final brand = _getSystemProp('ro.product.brand') ?? '';
      final model = _getSystemProp('ro.product.model') ?? '';
      final hardware = _getSystemProp('ro.hardware') ?? '';
      final board = _getSystemProp('ro.product.board') ?? '';

      // The crashing emulator profiles:
      // - brand: "google", model contains "sdk_gphone" or "emulator"
      // - hardware: "ranchu" (QEMU/goldfish emulator)
      // - board: "goldfish_arm64" or similar emulator board
      final isEmulator =
          brand.toLowerCase() == 'google' &&
          (model.toLowerCase().contains('sdk_gphone') ||
              model.toLowerCase().contains('emulator') ||
              hardware.toLowerCase() == 'ranchu' ||
              board.toLowerCase().contains('goldfish'));

      if (isEmulator) {
        debugPrint(
          "⚠️ Emulator detected — skipping WebView to prevent GPU crash",
        );
        return false;
      }

      return true;
    } catch (e) {
      // If we can't read props, assume safe (real device)
      return true;
    }
  }

  String? _getSystemProp(String key) {
    // Android system properties via /proc/cmdline or build props file
    try {
      final buildPropFile = File('/system/build.prop');
      if (buildPropFile.existsSync()) {
        final lines = buildPropFile.readAsLinesSync();
        for (final line in lines) {
          if (line.startsWith('$key=')) {
            return line.substring(key.length + 1).trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isProcessing = false;
  void _initWebView() {
    try {
      final wvc = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          /*
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
              debugPrint("✅ Current URL: $url");
              _checkUrl(url);
            },
            onWebResourceError: (error) {
              debugPrint("❌ WebView Error: ${error.description}");
              // Only fatal main-frame network errors → fallback
              // Do NOT trigger on sub-resource errors (fonts, analytics)
              final fatal = [
                'net::ERR_CONNECTION_REFUSED',
                'net::ERR_NAME_NOT_RESOLVED',
                'net::ERR_INTERNET_DISCONNECTED',
              ];
              if (fatal.any((e) => error.description.contains(e))) {
                _switchToFallback();
              }
            },
            onNavigationRequest: (_) => NavigationDecision.navigate,
          ),
*/
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  // Show processing overlay the moment Stripe redirects back to your server
                  if (_isRedirectUrl(url)) {
                    _isProcessing = true;
                  }
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isProcessing = false; // always clear
                });
              }
              debugPrint("✅ Current URL: $url");
              _checkUrl(url);
            },
            onWebResourceError: (error) {
              debugPrint("❌ WebView Error: ${error.description}");
              // Only fatal main-frame network errors → fallback
              // Do NOT trigger on sub-resource errors (fonts, analytics)
              final fatal = [
                'net::ERR_CONNECTION_REFUSED',
                'net::ERR_NAME_NOT_RESOLVED',
                'net::ERR_INTERNET_DISCONNECTED',
              ];
              if (fatal.any((e) => error.description.contains(e))) {
                _switchToFallback();
              }
            },
            onNavigationRequest: (_) => NavigationDecision.navigate,
          ),
        )
        ..loadRequest(Uri.parse(_paymentUrl));

      if (mounted) {
        setState(() {
          _webViewController = wvc;
          _useWebView = true;
        });
      }
    } catch (e) {
      // WebViewController() itself threw — shouldn't happen but just in case
      debugPrint("❌ WebView init threw: $e");
      _switchToFallback();
    }
  }

  void _checkUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('success') || lower.contains('payment_success')) {
      _handleSuccess();
    } else if (lower.contains('cancel') ||
        lower.contains('failed') ||
        lower.contains('payment_failed')) {
      _handleFailure("Payment failed or was cancelled");
    }
  }

  /*
I/flutter (31719): ✅ Current URL: http://10.10.20.52:6002/payment/success?session_id=cs_test_a1DgIHyMkLIVGev20O0ENh1nJmEIDgI3K3n6cQrgMrdOgOM4qI0LvAffCr
I/flutter (31719): ✅ Payment Successful
*/
  void _switchToFallback() {
    if (!mounted) return;
    setState(() {
      _useWebView = false;
      _fallbackReady = true;
      _isLoading = false;
    });
    _openInBrowser();
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_paymentUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.error("Could not open browser. Please try again.");
      }
    } catch (e) {
      debugPrint("❌ Browser launch error: $e");
      CustomSnackBar.error("Could not open browser");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: 'Payment',
        isBack: true,
        onTap: () => _handleFailure("Payment cancelled"),
      ),
      body: _useWebView ? _buildWebView() : _buildFallback(),
    );
  }

  // Widget _buildWebView() {
  //   if (_webViewController == null) return const LoadingWidget();
  //   return Stack(
  //     children: [
  //       WebViewWidget(controller: _webViewController!),
  //       if (_isLoading) const Positioned.fill(child: LoadingWidget()),
  //     ],
  //   );
  // }
  Widget _buildWebView() {
    if (_webViewController == null) return const LoadingWidget();
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController!),
        if (_isLoading) const Positioned.fill(child: LoadingWidget()),

        // ✅ Processing overlay — shown during redirect, on top of everything
        if (_isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Processing your payment…',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please do not close this screen',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.open_in_browser_rounded,
              size: 72,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Complete Your Payment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your payment page has been opened in the browser.\n'
              'Return here after completing payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Payment Page'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _openInBrowser,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                label: const Text('I\'ve Completed Payment'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
                onPressed: _handleSuccess,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _handleFailure("Payment cancelled"),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  bool _isRedirectUrl(String url) {
    final lower = url.toLowerCase();
    // fires when leaving Stripe's domain toward your backend
    return !lower.contains('stripe.com') && !lower.contains('checkout.stripe');
  }

  void _handleSuccess() {
    debugPrint("✅ Payment Successful");
    _resetPaymentUrl();
    Get.offAllNamed(Routes.congratulationsScreen);
  }

  void _handleFailure(String message) {
    debugPrint("❌ Payment Failed: $message");
    _resetPaymentUrl();
    Get.back();
    CustomSnackBar.error(message);
  }

  void _resetPaymentUrl() {
    controller.paymentUrl.value = '';
  }
}

// old code

/*
class WebPaymentScreen extends StatefulWidget {
  const WebPaymentScreen({super.key});

  @override
  State<WebPaymentScreen> createState() => _WebPaymentScreenState();
}

class _WebPaymentScreenState extends State<WebPaymentScreen> {
  final controller = Get.find<HomeVendorController>();
  bool _webViewFailed = false;
  bool _isLoading = true;

  String get paymentUrl => controller.paymentUrl.value;

  @override
  void initState() {
    super.initState();

    if (paymentUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleFailure("Payment URL not found");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (paymentUrl.isEmpty) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AuthAppBar(
        title: 'Payment',
        isBack: true,
        onTap: _onBackPressed,
      ),
      body: _webViewFailed
          ? _buildFallbackView()
          : WebPaymentView(
              paymentUrl: paymentUrl,
              onSuccess: _handleSuccess,
              onFailure: _handleFailure,
              onFallback: _switchToFallback,
              onLoadingChanged: (loading) {
                if (mounted) setState(() => _isLoading = loading);
              },
              isLoading: _isLoading,
            ),
    );
  }

  Widget _buildFallbackView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_browser, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Opening payment in browser',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete your payment in the browser.\nReturn here once done.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Payment Page'),
              onPressed: _openInBrowser,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _handleSuccess,
                  child: const Text('Payment Done ✓'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => _handleFailure("Payment cancelled"),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(paymentUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        CustomSnackBar.error("Could not open browser");
      }
    } catch (e) {
      debugPrint("❌ Browser launch error: $e");
      CustomSnackBar.error("Could not open browser");
    }
  }

  void _switchToFallback() {
    debugPrint("⚠️ WebView failed, switching to browser fallback");
    if (mounted) {
      setState(() => _webViewFailed = true);
    }
    _openInBrowser();
  }

  void _onBackPressed() {
    _handleFailure("Payment cancelled by user");
  }

  void _handleSuccess() {
    debugPrint("✅ Payment Successful");
    _resetPaymentUrl();
    Get.offAllNamed(Routes.congratulationsScreen);
  }

  void _handleFailure(String message) {
    debugPrint("❌ Payment Failed: $message");
    _resetPaymentUrl();
    Get.back();
    CustomSnackBar.error(message);
  }

  void _resetPaymentUrl() {
    controller.paymentUrl.value = '';
  }
}

*/
/*
class WebPaymentScreen extends StatefulWidget {
  const WebPaymentScreen({super.key});

  @override
  State<WebPaymentScreen> createState() => _WebPaymentScreenState();
}
class _WebPaymentScreenState extends State<WebPaymentScreen> {
  final controller = Get.find<HomeVendorController>();
  late final WebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // ✅ paymentUrl check করুন
    final paymentUrl = controller.paymentUrl.value;

    if (paymentUrl.isEmpty) {
      _handleFailure("Payment URL not found");
      return;
    }

    debugPrint("🔗 Loading Payment URL: $paymentUrl");

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
            debugPrint("✅ Current URL: $url");

            // ✅ Success check
            if (url.contains('success')) {
              _handleSuccess();
            }
            // ✅ Cancel/Failed check
            else if (url.contains('cancel') || url.contains('failed')) {
              _handleFailure("Payment failed or was cancelled");
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("❌ WebView Error: ${error.description}");
            _handleFailure("Failed to load payment page");
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(
        title: 'Payment',
        isBack: true,
      ),
      body: isLoading
          ? const LoadingWidget()
          : WebViewWidget(controller: _webViewController),
    );
  }

  void _handleSuccess() {
    debugPrint("✅ Payment Successful");

    // ✅ paymentUrl reset করুন
    controller.paymentUrl.value = '';

    Get.offAllNamed(Routes.congratulationsScreen);
  }

  void _handleFailure(String message) {
    debugPrint("❌ Payment Failed: $message");

    // ✅ paymentUrl reset করুন
    controller.paymentUrl.value = '';

    Get.back();
    CustomSnackBar.error(message);
  }
}
*/
