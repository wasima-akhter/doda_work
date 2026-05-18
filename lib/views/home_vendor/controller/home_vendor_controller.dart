import 'package:doda_work/views/home/model/home_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/api/services/api.dart';
import '../../../core/utils/basic_import.dart';
import '../../../widgets/web_payment_widget.dart';
import '../model/provider_status_response_model.dart';

class HomeVendorController extends GetxController {
  final RxInt selectedStatus = 0.obs;
  final RxBool isLoading = false.obs;

  RxString paymentUrl = ''.obs;

  // ✅ Accept loading
  RxBool isAcceptLoading = false.obs;

  // Constants for status types
  static const List<String> statusTypes = [
    "PENDING",
    "ACCEPTED",
    "COMPLETED",
    "DECLINED",
  ];

  final Map<String, PagingController<int, HomeServiceItem>> pagingControllers =
      {
        for (var status in statusTypes)
          status: PagingController(firstPageKey: 1),
      };

  final Map<String, bool> isLoadingMap = {
    for (var status in statusTypes) status: false,
  };

  @override
  void onInit() {
    _initializePagingControllers();
    fetch("PENDING", 1);
    super.onInit();
  }

  void _initializePagingControllers() {
    for (final entry in pagingControllers.entries) {
      final status = entry.key;
      final controller = entry.value;

      controller.addPageRequestListener((pageKey) {
        fetch(status, pageKey);
      });
    }
  }

  Future<ProviderStatusResponseModel> acceptRequest({
    required String requestId,
  }) async {
    Map<String, dynamic> inputBody = {
      'requestId': requestId,
      'action': 'ACCEPT',
    };

    return await ApiRequest.patch(
      fromJson: ProviderStatusResponseModel.fromJson,
      endPoint: ApiEndPoints.providerChangeStatus(),
      isLoading: isAcceptLoading,
      body: inputBody,

      // In acceptRequest — no changes needed except safety null-check
      onSuccess: (result) {
        if (result.data.requiresPayment) {
          final url = result.data.paymentUrl;

          if (url.isEmpty) {
            CustomSnackBar.error("Payment URL missing");
            return;
          }

          paymentUrl.value = url;
          debugPrint("🔗 Payment URL: $url");

          Get.back();
          Future.delayed(const Duration(milliseconds: 100), () {
            Get.to(() => const WebPaymentScreen());
          });
        } else {
          Get.back();
          CustomSnackBar.success(
            title: "Success",
            message: result.data.message,
          );
        }

        refreshAll();
      },
    );
  }

  Future<void> fetch(String status, int pageKey) async {
    if (isLoadingMap[status] == true) return;

    isLoadingMap[status] = true;

    try {
      final controller = pagingControllers[status]!;

      if (status == "PENDING") {
        final pendingResponse = await ApiClient.get(
          url: ApiEndPoints.providerService(status: "PENDING", page: pageKey),
        );

        final awaitingResponse = await ApiClient.get(
          url: ApiEndPoints.providerService(
            status: "AWAITING_PAYMENT",
            page: pageKey,
          ),
        );

        if (pendingResponse.statusCode == 200 &&
            awaitingResponse.statusCode == 200) {
          final pendingModel = HomeModel.fromJson(pendingResponse.body);
          final awaitingModel = HomeModel.fromJson(awaitingResponse.body);

          final List<HomeServiceItem> allItems = [
            ...(pendingModel.data?.requests ?? []),
            ...(awaitingModel.data?.requests ?? []),
          ];

          if (allItems.isNotEmpty) {
            final nextPageKey = pageKey + 1;
            controller.appendPage(allItems, nextPageKey);
          } else {
            controller.appendLastPage(allItems);
          }
        } else {
          _handleErrorResponse(controller, pendingResponse);
        }
      } else {
        final response = await ApiClient.get(
          url: ApiEndPoints.providerService(status: status, page: pageKey),
        );

        if (response.statusCode == 200) {
          await _handleSuccessResponse(response, controller, pageKey);
        } else {
          _handleErrorResponse(controller, response);
        }
      }
    } catch (e) {
      _handleException(status, e);
    } finally {
      isLoadingMap[status] = false;
    }
  }

  Future<void> _handleSuccessResponse(
    dynamic response,
    PagingController<int, HomeServiceItem> controller,
    int pageKey,
  ) async {
    try {
      final homeModel = HomeModel.fromJson(response.body);
      final newItems = homeModel.data?.requests ?? [];

      if (newItems.isNotEmpty) {
        final nextPageKey = pageKey + 1;
        controller.appendPage(newItems, nextPageKey);
      } else {
        controller.appendLastPage(newItems);
      }
    } catch (e) {
      controller.error = 'Failed to parse response: $e';
    }
  }

  void _handleErrorResponse(
    PagingController<int, HomeServiceItem> controller,
    dynamic response,
  ) {
    final errorMessage = response.body?["message"] ?? "Failed to load data";
    controller.error = errorMessage;

    if (controller.firstPageKey == 1) {
      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _handleException(String status, Object e) {
    pagingControllers[status]!.error = e.toString();
    debugPrint('Error fetching $status requests: $e');
  }

  Future<void> changeStatus({
    required String status,
    required String id,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final response = await ApiClient.patch(
        body: {"requestId": id, "action": status},
        url: ApiEndPoints.providerChangeStatus(),
      );

      if (response.statusCode == 200) {
        await _handleStatusChangeSuccess();
      } else {
        // _handleStatusChangeError(response);
      }
    } catch (e) {
      _handleStatusChangeException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleStatusChangeSuccess() async {
    for (final controller in pagingControllers.values) {
      controller.refresh();
    }

    Get.snackbar(
      "Success",
      "Status updated successfully!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _handleStatusChangeException(Object e) {
    Get.snackbar(
      "Error",
      "Network error occurred. Please try again.",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );

    debugPrint('Error changing status: $e');
  }

  Future<void> declineRequest({required String id}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await ApiClient.patch(
        body: {"requestId": id, "action": "DECLINED"},
        url: '${ApiEndPoints.baseUrl}${ApiEndPoints.providerChangeStatus()}',
      );

      if (response.statusCode == 200) {
        for (var c in pagingControllers.values) {
          c.refresh();
        }

        Get.snackbar(
          "Success",
          "Request declined successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response.body?["message"] ?? "Something went wrong",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    for (final controller in pagingControllers.values) {
      controller.refresh();
    }
  }

  String getStatusByIndex(int index) {
    return statusTypes[index];
  }

  String get currentStatus => statusTypes[selectedStatus.value];

  @override
  void onClose() {
    for (final controller in pagingControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
