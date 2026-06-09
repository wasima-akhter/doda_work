import 'package:doda_work/core/api/end_point/api_end_points.dart';
import 'package:doda_work/core/api/services/api_request.dart';
import 'package:get/get.dart';

import '../model/provider_report_models.dart';
/*
class CategoryController extends GetxController {
  final RxString expandedCategoryId = ''.obs;

  void toggleExpand(String categoryId) {
    debugPrint(categoryId);
    if (expandedCategoryId.value == categoryId) {
      expandedCategoryId.value = '';
      debugPrint("Empty");
    } else {
      debugPrint("Assign"
      );
      expandedCategoryId.value = categoryId;
    }
  }

  final RxList<CategoryItem> allCategory = <CategoryItem>[].obs;
  final RxList<CategoryItem> filteredCategory = <CategoryItem>[].obs;
  final RxList<CategoryItemSubcategory> availableSubcategories = <CategoryItemSubcategory>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> getCategory() async {
    try {
      isLoading.value = true;
      final data = await ApiClient.get(url: ApiEndPoints.categoryAll);
      if (data.statusCode == 200) {
        final allItems = AllCategoryModel.fromJson(data.body);
        allCategory.assignAll(allItems.data ?? []);
        filteredCategory.assignAll(
          allCategory.where((c) => (c.subcategories?.isNotEmpty ?? false)).toList(),
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
    super.onReady();
  }
}

*/

class CategoryController extends GetxController {
  final Rxn<ProviderReportData> reportData = Rxn<ProviderReportData>();

  final RxBool isLoading = false.obs;

  Future<void> getReport() async {
    try {
      isLoading.value = true;

      final data = await ApiClient.get(url: ApiEndPoints.providerReports);

      if (data.statusCode == 200) {
        final report = ProviderReportModel.fromJson(data.body);

        reportData.value = report.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReport() async {
    await getReport();
  }

  @override
  void onReady() {
    getReport();
    super.onReady();
  }
}
