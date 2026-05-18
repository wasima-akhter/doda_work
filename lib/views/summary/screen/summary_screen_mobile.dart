part of 'summary_screen.dart';

class SummaryScreenMobile extends GetView<SummaryController> {
  const SummaryScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final SummaryModel model = Get.arguments;
    return Scaffold(
      appBar: AuthAppBar(title: 'Service Summary'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Space.height.v10,
            ImageHeaderWidget(image: model.attachments?.firstOrNull),
            Space.height.v10,

            RequestInfoCard(
              requestId: model.requestId ?? "",
              category: model.categoryName ?? "",
              subcategory: model.subcategory ?? "",
              priority: model.priority ?? "",
              customerName: model.customerName ?? "",
              address: model.address ?? "",
            ),
            Space.height.v20,
            if (model.isUser)
              TextWidget(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: Dimensions.verticalSize * 0.25,
                ),
                'Would you like to tell us more about your request?',
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.titleMedium,
              ),

            RequestTextBoxWidget(
              description: model.description,
              attachments: model.attachments,
            ),
            Space.height.v20,

            AppStorage.isUser
                ? SizedBox.shrink()
                : PrimaryButtonWidget(
                    title: model.status == 'IN_PROGRESS'
                        ? 'Mark as complete'
                        : 'Prove Submitted',
                    onPressed:
                        model.status == 'COMPLETED' ||
                            model.status == 'APPROVED'
                        ? () {}
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CompleteTaskDialog(model: model);
                              },
                            );
                          },
                  ),

            if (model.completionProof != null &&
                model.completionProof!.isNotEmpty) ...[
              Space.height.v20,
              TextWidget(
                'Completion Proof',
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.titleMedium,
              ),
              Space.height.v10,
              if (AppStorage.isUser)
                Obx(
                  () => CompletionProofGrid(
                    proofs: model.completionProof!,
                    providerNotes: model.providerNotes,
                    onAccept: () => controller.showReviewBottomSheet(
                      id: model.id ?? '',
                      providerId: model.completedById ?? '',
                    ),
                    isLoading: controller.isLoadingAccept.value,
                  ),
                )
              else
                CompletionProofGrid(
                  proofs: model.completionProof!,
                  providerNotes: model.providerNotes,
                  onAccept: () {},
                ),
            ],
            Space.height.v20,
          ],
        ),
      ),
    );
  }
}

class CompletionProofGrid extends StatelessWidget {
  final SummaryModel model = Get.arguments;

  final List<CompletionProof> proofs;
  final String? providerNotes;
  final VoidCallback? onAccept;
  final bool isLoading;

  CompletionProofGrid({
    super.key,
    required this.proofs,
    this.providerNotes,
    this.onAccept,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: proofs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: Dimensions.widthSize * 0.8,
            crossAxisSpacing: Dimensions.widthSize * 0.8,
          ),
          itemBuilder: (context, index) {
            final item = proofs[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        color: CustomColors.blackColor.withValues(alpha: 0.9),
                        alignment: Alignment.center,
                        child: Hero(
                          tag: item.url ?? index.toString(),
                          child: CachedNetworkImage(
                            imageUrl: item.url ?? '',
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.image_not_supported,
                              color: CustomColors.whiteColor,
                              size: Dimensions.iconSizeLarge * 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: item.url ?? index.toString(),
                  child: Container(
                    color: Colors.grey.shade200,
                    child: CachedNetworkImage(
                      imageUrl: item.url ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: CustomColors.primary,
                          strokeWidth: 2.w,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade600,
                        size: Dimensions.iconSizeLarge,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (providerNotes != null && providerNotes!.isNotEmpty) ...[
          Space.height.v15,
          TextWidget(
            "Provider Notes:",
            fontSize: Dimensions.titleMedium,
            fontWeight: FontWeight.w600,
            color: CustomColors.blackColor,
          ),
          Space.height.v5,
          TextWidget(
            providerNotes!,
            fontSize: Dimensions.bodyMedium,
            fontWeight: FontWeight.w400,
            color: CustomColors.grayShade,
            maxLines: 10,
          ),
        ],
        if (onAccept != null) ...[
          Space.height.v20,
          PrimaryButtonWidget(
            title: model.status == 'COMPLETED'
                ? 'Approve Completion'
                : 'Approved',
            onPressed: model.status == 'COMPLETED' ? onAccept! : () {},
            fontWeight: FontWeight.w600,
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }
}
