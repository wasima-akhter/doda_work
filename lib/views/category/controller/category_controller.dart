import 'dart:developer';

import '../../../core/utils/basic_import.dart';
import '../model/all_category_model.dart';
import '../model/provider_report_models.dart';
import '../screen/category_screen.dart';

class CategoryController extends GetxController {
  final RxString expandedCategoryId = ''.obs;

  void toggleExpand(String categoryId) {
    debugPrint(categoryId);
    if (expandedCategoryId.value == categoryId) {
      expandedCategoryId.value = '';
      debugPrint("Empty");
    } else {
      debugPrint("Assign");
      expandedCategoryId.value = categoryId;
    }
  }

  final RxList<CategoryItem> allCategory = <CategoryItem>[].obs;
  final RxList<CategoryItem> filteredCategory = <CategoryItem>[].obs;
  final RxList<CategoryItemSubcategory> availableSubcategories =
      <CategoryItemSubcategory>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> getCategory() async {
    try {
      isLoading.value = true;
      final data = await ApiClient.get(url: ApiEndPoints.categoryAll);
      if (data.statusCode == 200) {
        final allItems = AllCategoryModel.fromJson(data.body);
        allCategory.assignAll(allItems.data ?? []);
        filteredCategory.assignAll(
          allCategory
              .where((c) => (c.subcategories?.isNotEmpty ?? false))
              .toList(),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterSubcategories(String categoryId) {
    final category = allCategory.firstWhereOrNull((c) => c.id == categoryId);
    availableSubcategories.assignAll(category?.subcategories ?? []);
  }

  @override
  void onReady() {
    getCategory();
    getReports();
    super.onReady();
  }

  //. ----------------Dashboard-------------//
  RxBool isReportLoading = false.obs;
  /*
  RxList<DashboardItemModel> dashboardItems = <DashboardItemModel>[
    DashboardItemModel(
      title: "Total Request",
      value: "120",
      subtitle: "12 New Request",
      percentage: "+16.56%",
      isPositive: true,
      icon: Icons.menu,
      iconColor: Colors.orange,
    ),
    DashboardItemModel(
      title: "Total Accepted",
      value: "113",
      subtitle: "5 Upcoming Task",
      percentage: "+16.56%",
      isPositive: true,
      icon: Icons.check_circle_outline,
      iconColor: Colors.orange,
    ),
    DashboardItemModel(
      title: "Total Completed",
      value: "56",
      subtitle: "3 Uncompleted Task",
      percentage: "+16.56%",
      isPositive: true,
      icon: Icons.verified,
      iconColor: Colors.blue,
    ),
    DashboardItemModel(
      title: "Total Rejected",
      value: "7",
      subtitle: "5 Rejection this month",
      percentage: "-4.56%",
      isPositive: false,
      icon: Icons.cancel,
      iconColor: Colors.red,
    ),
    DashboardItemModel(
      title: "Total Earning",
      value: "\$5,566",
      subtitle: "\$1,206 this month",
      percentage: "+16.56%",
      isPositive: true,
      icon: Icons.attach_money,
      iconColor: Colors.orange,
    ),
  ].obs;
*/

  final Rxn<ProviderReportData> reportData = Rxn<ProviderReportData>();

  final RxList<DashboardItemModel> dashboardItems = <DashboardItemModel>[].obs;

  Future<void> getReports() async {
    try {
      isReportLoading.value = true;

      final data = await ApiClient.get(url: ApiEndPoints.providerReports);

      if (data.statusCode == 200) {
        final report = ProviderReportModel.fromJson(data.body);

        reportData.value = report.data;

        _prepareDashboardCards();
      }
    } finally {
      isReportLoading.value = false;
    }
  }

  void _prepareDashboardCards() {
    final cards = reportData.value?.cards;

    if (cards == null) return;

    log("cards.totalRequests?.direction: ${cards.totalRequests?.direction}");

    dashboardItems.assignAll([
      DashboardItemModel(
        title: "Total Request",
        value: "${cards.totalRequests?.current ?? 0}",
        subtitle: "${cards.totalRequests?.newRequestsCount ?? 0} New Request",
        percentage: formatPercentage(cards.totalRequests),
        isPositive: cards.totalRequests?.direction.toLowerCase() == "up",
        icon: Assets.icons.menuDash,
      ),

      DashboardItemModel(
        title: "Total Accepted",
        value: "${cards.totalAccepted?.current ?? 0}",
        subtitle:
            "${cards.totalAccepted?.upcomingTasksCount ?? 0} Upcoming Task",
        percentage: formatPercentage(cards.totalAccepted),
        isPositive: cards.totalAccepted?.direction.toLowerCase() == "up",
        icon: Assets.icons.successDash,
      ),

      DashboardItemModel(
        title: "Total Completed",
        value: "${cards.totalCompleted?.current ?? 0}",
        subtitle:
            "${cards.totalCompleted?.incompleteTasksCount ?? 0} Uncompleted Task",
        percentage: formatPercentage(cards.totalCompleted),
        isPositive: cards.totalCompleted?.direction.toLowerCase() == "up",
        icon: Assets.icons.successDashWaved,
      ),

      DashboardItemModel(
        title: "Total Purchase",
        value: cards.totalPurchase?.current.toStringAsFixed(0) ?? '0',
        subtitle:
            "${formatCurrencySymbol(cards.totalPurchase?.currency)}${cards.totalPurchase?.previous.toStringAsFixed(0) ?? '0'} previous period",
        percentage: formatPercentage(cards.totalPurchase),
        isPositive: cards.totalPurchase?.direction.toLowerCase() == "up",
        icon: Assets.icons.currency,
      ),
    ]);
  }
}

String formatCurrencySymbol(String? currency) {
  if (currency == null || currency.isEmpty) return "\$";

  final code = currency.toLowerCase();

  if (code == "cad") return "C\$";
  if (code == "usd") return "\$";

  return currency; // fallback from API
}

String formatPercentage(dynamic card) {
  if (card == null) return "0%";

  final raw = card.percentage.toString();
  final direction = (card.direction ?? "").toLowerCase();

  final hasSign = raw.startsWith("+") || raw.startsWith("-");

  final sign = hasSign
      ? "" // already has + or -
      : (direction == "up"
            ? "+"
            : direction == "down"
            ? "-"
            : "");

  return "$sign$raw%";
}
