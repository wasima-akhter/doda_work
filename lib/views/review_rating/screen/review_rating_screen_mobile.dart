import 'package:doda_work/views/review_rating/screen/review_rating_screen.dart';

import '../../../core/utils/basic_import.dart';
import '../../../core/utils/extensions.dart';
import '../../../widgets/auth_app_bar.dart';
import '../controller/review_rating_controller.dart';

class ReviewRatingScreenMobile extends GetView<ReviewRatingController> {
  const ReviewRatingScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch reviews when screen opens
    controller.getProviderReviews();

    return Scaffold(
      appBar: AuthAppBar(title: 'Customer Review'),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.reviewsList.isEmpty) {
            return Center(
              child: Text(
                'No reviews available',
                style: TextStyle(
                  fontSize: Dimensions.titleSmall,
                  color: CustomColors.primary,
                ),
              ),
            );
          }

          return ListView(
            padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
            children: [
              TopTextWidget(),

              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.reviewsList.length,
                itemBuilder: (context, index) {
                  final review = controller.reviewsList[index];
                  return ReviewCardWidget(
                    date: review.createdAt?.split('T').first ?? '',
                    reviewerImage: review.user?.profileImage != null
                        ? '${ApiEndPoints.baseUrl}${review.user!.profileImage}'
                        : 'https://picsum.photos/200/300?random=$index',
                    reviewerName: review.user?.name ?? 'Anonymous',
                    rating: review.rating ?? 0,

                    comment: review.review ?? 'hlloe',
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
