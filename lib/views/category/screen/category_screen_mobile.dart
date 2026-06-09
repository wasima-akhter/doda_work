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
        return Center(child: CircularProgressIndicator());
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
part of 'dashboard_screen.dart';

class DashboardScreenMobile extends GetView<DashboardController> {
  const DashboardScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.handshake_outlined),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                icon: Icons.home_outlined,
                title: "Home",
              ),
              SizedBox(width: 40),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                title: "Chat",
              ),
              _NavItem(
                icon: Icons.person_outline,
                title: "Profile",
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView(
                  children: const [
                    DashboardCard(
                      title: "Total Request",
                      value: "120",
                      subtitle: "12 New Request",
                      percentage: "+16.56%",
                      isPositive: true,
                      icon: Icons.menu,
                      iconColor: Colors.orange,
                    ),

                    DashboardCard(
                      title: "Total Accepted",
                      value: "113",
                      subtitle: "5 Upcoming Task",
                      percentage: "+16.56%",
                      isPositive: true,
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.orange,
                    ),

                    DashboardCard(
                      title: "Total Completed",
                      value: "56",
                      subtitle: "3 Uncompleted Task",
                      percentage: "+16.56%",
                      isPositive: true,
                      icon: Icons.verified,
                      iconColor: Colors.blue,
                    ),

                    DashboardCard(
                      title: "Total Rejected",
                      value: "7",
                      subtitle: "5 Rejection this month",
                      percentage: "-4.56%",
                      isPositive: false,
                      icon: Icons.cancel,
                      iconColor: Colors.red,
                    ),

                    DashboardCard(
                      title: "Total Earning",
                      value: "\$5,566",
                      subtitle: "\$1,206 this month",
                      percentage: "+16.56%",
                      isPositive: true,
                      icon: Icons.attach_money,
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
