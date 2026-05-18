part of 'notification_screen.dart';

class NotificationScreenMobile extends GetView<NotificationController> {
  const NotificationScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Notification'),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.pagingController.refresh();
        },
        child: PagedListView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          pagingController: controller.pagingController,
          builderDelegate: PagedChildBuilderDelegate<NotificationItem>(
            itemBuilder: (context, notification, index) {
              return Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
                  border: Border.all(color: Colors.grey.withAlpha(555)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(0x03),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  spacing: 6,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextWidget(
                            (notification.title ?? "No title"),
                            color: CustomColors.primary,
                            maxLines: 3,
                            fontSize: Dimensions.titleSmall,
                            fontWeight: FontWeight.w500,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextWidget(
                          DateFormat('hh:mm a').format(
                            (notification.createdAt ?? DateTime.now())
                                .toLocal(),
                          ),
                          fontSize: Dimensions.titleSmall * 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    TextWidget(
                      notification.message ?? "No message",
                      fontSize: Dimensions.titleSmall * 0.8,
                      maxLines: 3,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.grayShade,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
