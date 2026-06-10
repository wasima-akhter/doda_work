part of 'category_screen.dart';
/*
class CategoryScreenMobile extends GetView<CategoryController> {
  const CategoryScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Categories"),
      body: SafeArea(child: ExpandableCardList()),
    );
  }
}

class ExpandableCardList extends GetView<CategoryController> {
  const ExpandableCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: CustomColors.primary));
      }
      return ListView.builder(
        itemCount: controller.allCategory.length,
        itemBuilder: (context, index) {
          final category = controller.allCategory[index];
          return GestureDetector(
            onTap: () => controller.toggleExpand(category.id ?? ""),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextWidget(
                            category.name ?? "Unnamed Category",
                            // Display category name
                            fontSize: Dimensions.titleSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(() {
                          final isExpanded =
                              controller.expandedCategoryId.value ==
                              category.id;
                          return Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: CustomColors.primary,
                          );
                        }),
                      ],
                    ),
                    Obx(() {
                      final isExpanded =
                          controller.expandedCategoryId.value == category.id;
                      return isExpanded
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var subcategory
                                        in category.subcategories ?? [])
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: TextWidget(
                                          "➤ ${subcategory.name ?? 'Unnamed Subcategory'}",
                                          // Subcategory name
                                          color: CustomColors.blackColor
                                              .withAlpha(200),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            )
                          : SizedBox();
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
*/

class CategoryScreenMobile extends GetView<CategoryController> {
  const CategoryScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(title: "Dashboard"),
      body: SafeArea(child: DashboardCardList()),
    );
  }
}

class DashboardCardList extends GetView<CategoryController> {
  const DashboardCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isReportLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: CustomColors.primary),
        );
      }

      return RefreshIndicator(
        color: CustomColors.primary,
        onRefresh: () async {
          controller.getReports();
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.dashboardItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = controller.dashboardItems[index];

            return DashboardCard(item: item);
          },
        ),
      );
    });
  }
}

class DashboardCard extends StatelessWidget {
  final DashboardItemModel item;

  const DashboardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        // color: CustomColors.whiteColor,
        color: CustomColors.grayShade.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withAlpha(10),
          //   blurRadius: 10,
          //   offset: const Offset(0, 4),
          // ),
        ],
      ),
      child: Row(
        children: [
          /// Icon Box
          Container(
            width: 50.w,
            height: 50.w,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CustomColors.whiteColor.withValues(alpha: 0.99),
              borderRadius: BorderRadius.circular(8),
            ),
            // child: Icon(item.icon, size: 20, color: item.iconColor),
            child: SafeSvgAsset(assetPath: item.icon),
          ),

          const SizedBox(width: 16),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  item.title,
                  fontSize: Dimensions.titleSmall,
                  fontWeight: FontWeight.w500,
                ),

                const SizedBox(height: 4),

                TextWidget(
                  item.value,
                  fontSize: Dimensions.titleLarge,
                  fontWeight: FontWeight.bold,
                ),

                const SizedBox(height: 4),

                TextWidget(
                  item.subtitle,
                  color: Colors.grey,
                  fontSize: Dimensions.bodySmall,
                ),
              ],
            ),
          ),

          /// Percentage
          Column(
            children: [
              Row(
                children: [
                  TextWidget(
                    item.percentage,
                    fontWeight: FontWeight.w600,
                    fontSize: Dimensions.titleSmall,
                    color: item.isPositive ? Colors.green : Colors.red,
                  ),

                  const SizedBox(width: 4),

                  Icon(
                    item.isPositive
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    color: item.isPositive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardItemModel {
  final String title;
  final String value;
  final String subtitle;
  final String percentage;
  final bool isPositive;
  final String icon;
  final Color? iconColor;

  DashboardItemModel({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.percentage,
    required this.isPositive,
    required this.icon,
    this.iconColor,
  });
}
