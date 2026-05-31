import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../../summary/model/summary_model.dart';
import '../controller/home_controller.dart';
import '../model/home_model.dart';
import '../widget/category_widget.dart';
import '../widget/home_app_bar_widget.dart';
import 'home_screen.dart';

class HomeScreenMobile extends GetView<HomeController> {
  const HomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> statusText = ['Pending', 'Ongoing', 'Completed'];
    final List<String> statusApi = ['PENDING', 'IN_PROGRESS', 'COMPLETED'];

    return DefaultTabController(
      length: statusText.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: Dimensions.appBarHeight * 2.25,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: HomeAppBarWidgetView(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshRequestList();
          },
          child: Column(
            children: [
              SizedBox(height: 12),
              CategoryWidgetView(),
              Obx(() => _buildTabBar(controller, statusText)),
              Space.height.v10,
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(statusText.length, (index) {
                    final status = statusApi[index];
                    return KeepAlivePage(
                      child: RefreshIndicator(
                        onRefresh: () async =>
                            controller.refreshStatusData(status),
                        child: CustomScrollView(
                          slivers: [
                            PagedSliverList<int, HomeServiceItem>(
                              pagingController:
                                  controller.pagingControllers[status]!,
                              builderDelegate: PagedChildBuilderDelegate<HomeServiceItem>(
                                itemBuilder: (context, item, itemIndex) {
                                  return CustomStatusCardWidget(
                                    index: itemIndex,
                                    requestId: item.requestId ?? "",
                                    category: item.serviceCategory?.name ?? "",
                                    subCategory: item.subcategory ?? "",
                                    address:
                                        'Postal Code : ${item.postalCode ?? ""}',
                                    image: item.attachments.first,
                                    isUser: true,
                                    status: status,
                                    customerId: item.customerId,

                                    onTap: () {
                                      Get.toNamed(
                                        Routes.summaryScreen,
                                        arguments: SummaryModel(
                                          isUser: true,
                                          requestId: item.requestId,
                                          customerEmail: item.customerId?.email,

                                          categoryIcon:
                                              item.serviceCategory?.icon,
                                          categoryName:
                                              item.serviceCategory?.name,
                                          customerPhone: item.customerPhone,
                                          customerName: item.customerId?.name,
                                          priority: item.priority,
                                          address: item.address,
                                          subcategory: item.subcategory,
                                          description: item.description,
                                          attachments: item.attachments,
                                          completionProof: item.completionProof,
                                          providerNotes: item.providerNotes,
                                          id: item.id,
                                          status: item.status,
                                          completedById: item.completedById,
                                        ),
                                      );
                                    },
                                  );
                                },

                                noItemsFoundIndicatorBuilder: (_) =>
                                    SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.45,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: CustomColors.primary
                                                    .withValues(alpha: 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.assignment_outlined,
                                                size: 72,
                                                color: CustomColors.primary,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  Dimensions.verticalSize * 2.5,
                                            ),
                                            Text(
                                              "No ${statusText[index]} Requests",
                                              style: TextStyle(
                                                fontSize: Dimensions.titleLarge,
                                                fontWeight: FontWeight.w700,
                                                color: CustomColors.blackColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  Dimensions.verticalSize * 0.8,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    Dimensions.widthSize * 4,
                                              ),
                                              child: Text(
                                                "You don't have any ${statusText[index].toLowerCase()} requests at the moment. Explore services to book now!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      Dimensions.bodyMedium,
                                                  fontWeight: FontWeight.w400,
                                                  color: CustomColors.grayShade,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                firstPageErrorIndicatorBuilder: (_) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      "Error loading ${statusText[index]} requests",
                                      style: TextStyle(
                                        fontSize: Dimensions.titleSmall,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                                newPageErrorIndicatorBuilder: (_) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      "Error loading more ${statusText[index]} requests",
                                      style: TextStyle(
                                        fontSize: Dimensions.titleSmall,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(HomeController controller, List<String> statusText) {
    return TabBar(
      tabAlignment: TabAlignment.fill,
      isScrollable: false,
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      enableFeedback: false,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: (index) => controller.selectedStatus.value = index,
      tabs: List.generate(statusText.length, (index) {
        final isSelected = controller.selectedStatus.value == index;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: Dimensions.defaultHorizontalSize * 0.4,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.widthSize * 1.2,
            vertical: Dimensions.verticalSize * 0.32,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? CustomColors.primary
                : CustomColors.primary.withAlpha(85),
            borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          ),
          child: Center(
            child: TextWidget(
              statusText[index],
              fontWeight: FontWeight.w500,
              fontSize: Dimensions.titleSmall,
              color: isSelected
                  ? CustomColors.whiteColor
                  : CustomColors.blackColor,
            ),
          ),
        );
      }),
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
