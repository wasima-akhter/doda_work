import 'package:doda_work/core/utils/app_storage.dart';
import 'package:doda_work/views/home/model/home_model.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/utils/basic_import.dart';
import '../model/request_model.dart';

class HomeController extends GetxController {
  // Currently selected status index
  final RxInt selectedStatus = 0.obs;

  /// Paging controller for general request list
  final PagingController<int, RequestService> requestPagingController =
      PagingController(firstPageKey: 1);

  /// Paging controllers for Home Services by status
  final Map<String, PagingController<int, HomeServiceItem>> pagingControllers =
      {
        "PENDING": PagingController(firstPageKey: 1),
        "IN_PROGRESS": PagingController(firstPageKey: 1),
        "COMPLETED": PagingController(firstPageKey: 1),
      };

  /// Loading state to prevent multiple API calls
  final Map<String, bool> isLoadingMap = {
    "PENDING": false,
    "IN_PROGRESS": false,
    "COMPLETED": false,
  };

  // =============================
  // FETCH HOME SERVICES
  // =============================
  Future<void> fetch(String status, int pageKey, String statusR) async {
    if (isLoadingMap[status] == true) return;
    isLoadingMap[status] = true;

    final controller = pagingControllers[status]!;

    try {
      // ✅ COMPLETED tab এর জন্য APPROVED status ও fetch করা হবে
      if (status == "COMPLETED") {
        final completedResponse = await ApiClient.get(
          url: ApiEndPoints.myService(page: pageKey, status: "COMPLETED"),
        );

        final approvedResponse = await ApiClient.get(
          url: ApiEndPoints.myService(page: pageKey, status: "APPROVED"),
        );

        List<HomeServiceItem> completedItems = [];
        List<HomeServiceItem> approvedItems = [];

        if (completedResponse.statusCode == 200) {
          completedItems =
              HomeModel.fromJson(completedResponse.body).data?.requests ?? [];
        }

        if (approvedResponse.statusCode == 200) {
          approvedItems =
              HomeModel.fromJson(approvedResponse.body).data?.requests ?? [];
        }

        // ✅ দুটি list merge করা হলো
        final allItems = [...completedItems, ...approvedItems];

        if (allItems.isEmpty) {
          controller.appendLastPage(allItems);
        } else {
          controller.appendPage(allItems, pageKey + 1);
        }
      } else {
        // অন্যান্য status এর জন্য normal fetch
        final response = await ApiClient.get(
          url: ApiEndPoints.myService(page: pageKey, status: statusR),
        );

        if (response.statusCode == 200) {
          final newItems =
              HomeModel.fromJson(response.body).data?.requests ?? [];

          if (newItems.isEmpty) {
            controller.appendLastPage(newItems);
          } else {
            controller.appendPage(newItems, pageKey + 1);
          }
        } else {
          controller.error = 'Error fetching data';
        }
      }
    } catch (e) {
      controller.error = e.toString();
    } finally {
      isLoadingMap[status] = false;
    }
  }

  // =============================
  // FETCH REQUEST SERVICES
  // =============================
  Future<void> fetchRequestList(int pageKey, String statusR) async {
    try {
      final token = AppStorage.token;
      final url = Uri.parse(
        ApiEndPoints.myService(page: pageKey, status: statusR),
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded["data"]["requests"] ?? [];

        final newItems = list.map((e) => RequestService.fromJson(e)).toList();

        if (newItems.isEmpty) {
          requestPagingController.appendLastPage(newItems);
        } else {
          requestPagingController.appendPage(newItems, pageKey + 1);
        }
      } else {
        requestPagingController.error = "Error fetching request data";
      }
    } catch (e) {
      requestPagingController.error = e.toString();
    }
  }

  // =============================
  // INIT
  // =============================
  @override
  void onInit() {
    super.onInit();

    pagingControllers.forEach((status, controller) {
      controller.addPageRequestListener((pageKey) {
        fetch(status, pageKey, status);
      });
    });

    // Fetch first page for all statuses
    fetch("PENDING", 1, "PENDING");
    fetch("IN_PROGRESS", 1, "IN_PROGRESS");
    fetch("COMPLETED", 1, "COMPLETED");

    // Setup paging listener for request list
    requestPagingController.addPageRequestListener((pageKey) {
      fetchRequestList(pageKey, 'PENDING');
    });
  }

  // =============================
  // REFRESH FUNCTIONS
  // =============================
  Future<void> refreshStatusData(String status) async {
    pagingControllers[status]?.refresh();
  }

  Future<void> refreshRequestList() async {
    requestPagingController.refresh();
  }
}
