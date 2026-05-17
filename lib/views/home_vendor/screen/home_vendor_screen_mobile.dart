part of 'home_vendor_screen.dart';

class HomeVendorScreenMobile extends GetView<HomeVendorController> {
  const HomeVendorScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: HomeVendorController.statusTypes.length,
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: Dimensions.appBarHeight * 2.25,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: HomeAppBarWidgetView(),
    );
  }

  Widget _buildBody() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              height: 170.h, // adjust based on your UI
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    WelcomeSection(),

                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Obx(() => _buildTabBar(controller)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },

      body: _buildTabViews(),
    );
  }

  SliverToBoxAdapter _buildTabBarSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [Obx(() => _buildTabBar(controller))]),
      ),
    );
  }

  Widget _buildTabBar(HomeVendorController controller) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      enableFeedback: false,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: _onTabChanged,
      tabs: List.generate(
        HomeVendorController.statusTypes.length,
        (index) => _buildTabItem(controller, index),
      ),
    );
  }

  void _onTabChanged(int value) {
    controller.selectedStatus.value = value;
    final status = HomeVendorController.statusTypes[value];
    final pagingController = controller.pagingControllers[status]!;

    if (pagingController.itemList == null ||
        pagingController.itemList!.isEmpty ||
        pagingController.error != null) {
      controller.fetch(status, 1);
    }
  }

  Widget _buildTabItem(HomeVendorController controller, int index) {
    final isSelected = controller.selectedStatus.value == index;
    final statusText = HomeVendorController.statusTypes[index];

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? CustomColors.primary
            : CustomColors.primary.withAlpha(858),
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
      ),
      child: Center(
        child: TextWidget(
          statusText,
          fontWeight: FontWeight.w400,
          fontSize: Dimensions.bodySmall,
          color: isSelected ? CustomColors.whiteColor : CustomColors.blackColor,
        ),
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(HomeVendorController.statusTypes.length, (index) {
        final status = HomeVendorController.statusTypes[index];
        return KeepAlivePage(child: _buildRequestList(status));
      }),
    );
  }

  Widget _buildRequestList(String status) {
    return RefreshIndicator(
      onRefresh: () => _refreshStatusList(status),
      child: PagedListView<int, HomeServiceItem>(
        pagingController: controller.pagingControllers[status]!,
        builderDelegate: PagedChildBuilderDelegate<HomeServiceItem>(
          firstPageProgressIndicatorBuilder: (_) => _buildLoadingIndicator(),
          newPageProgressIndicatorBuilder: (_) => _buildLoadingIndicator(),
          noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(status),
          firstPageErrorIndicatorBuilder: (_) => _buildErrorState(status),
          itemBuilder: (context, item, itemIndex) {
            return _buildRequestCard(item, status, itemIndex);
          },
        ),
      ),
    );
  }

  Future<void> _refreshStatusList(String status) async {
    controller.pagingControllers[status]!.refresh();
  }

  Widget _buildRequestCard(HomeServiceItem item, String status, int itemIndex) {
    return CustomStatusCardWidget(
      index: itemIndex,
      customerId: item.customerId,
      requestId: item.requestId ?? "N/A",
      category: item.serviceCategory?.name ?? "No Category",

      subCategory: item.subcategory ?? "No Subcategory",
      address: 'Postal Code : ${item.postalCode ?? ""}',
      image: (item.attachments.isNotEmpty) ? item.attachments.first : '',
      leadPrice: item.leadPrice,
      status: status,
      isUser: false,
      onTapAccept: () => _handleStatusChange(item, "ACCEPT"),
      onTapDecline: () {
        if (item.id == null) {
          _showErrorSnackbar("Invalid request ID");
          return;
        }
        controller.declineRequest(id: item.id!);
      },
      onTapComplete: () => _handleStatusChange(item, "COMPLETED"),
      onTap: () => status == "PENDING"
          ? _showErrorSnackbar("Request not yet accepted")
          : _navigateToSummary(item),
    );
  }

  void _handleStatusChange(HomeServiceItem item, String newStatus) async {
    if (item.id == null) {
      _showErrorSnackbar("Unable to process request - Invalid Request ID");
      return;
    }

    if (newStatus == "ACCEPT") {
      Get.dialog(
        PopScope(
          canPop: false,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: CustomColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Processing request...',
                      style: TextStyle(
                        fontSize: Dimensions.titleMedium,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await controller.acceptRequest(requestId: item.id!);

      if (controller.paymentUrl.value.isEmpty) {
        Get.back();
      }
    } else {
      await controller.changeStatus(status: newStatus, id: item.id!);
    }
  }

  void _navigateToSummary(HomeServiceItem item) {
    Get.toNamed(
      Routes.summaryScreen,
      arguments: SummaryModel(
        isUser: false,
        requestId: item.requestId,
        categoryIcon: item.serviceCategory?.icon,
        categoryName: item.serviceCategory?.name,
        customerPhone: item.customerPhone,
        customerName: item.customerId?.name,
        priority: item.priority,
        address: item.address,
        subcategory: item.subcategory,
        description: item.description,
        attachments: item.attachments,
        id: item.id,
        status: item.status,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Container(
      // padding: EdgeInsets.symmetric(
      //   horizontal: Dimensions.defaultHorizontalSize,
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            // height: 110.h,
            // width: 110.h,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: CustomColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              child: Icon(
                Icons.assignment_outlined,
                color: CustomColors.primary,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          TextWidget(
            "No ${status.toLowerCase()} requests",
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            fontSize: Dimensions.titleMedium,
            color: CustomColors.blackColor,
          ),

          SizedBox(height: 10.h),

          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: TextWidget(
              "When you have ${status.toLowerCase()} requests, they'll appear here",
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
              fontSize: Dimensions.bodyMedium,
              color: CustomColors.grayShade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String status) {
    return SizedBox(
      height: Get.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.red.shade400,
            ),
            Space.height.v20,
            TextWidget(
              "Failed to load requests",
              fontWeight: FontWeight.w600,
              fontSize: Dimensions.bodyLarge,
              color: Colors.grey.shade700,
            ),
            Space.height.v5,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextWidget(
                "Please check your connection and try again",
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.bodySmall,
                color: Colors.grey.shade500,
                textAlign: TextAlign.center,
              ),
            ),
            Space.height.v10,
            ElevatedButton(
              onPressed: () => controller.fetch(status, 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({required this.child, super.key});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

//
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
