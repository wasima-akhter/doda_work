part of '../screen/summary_screen.dart';

class RequestTextBoxWidget extends GetView<SummaryController> {
  const RequestTextBoxWidget({this.attachments, this.description, super.key});
  final String? description;
  final List<String?>? attachments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: Dimensions.verticalSize * 0.25,
          ),
          'Request',
          color: CustomColors.blackColor,
        ),
        Container(
          padding: EdgeInsets.all(Dimensions.paddingSize * 0.25),
          decoration: BoxDecoration(
            border: Border.all(color: CustomColors.disableColor),
            borderRadius: BorderRadiusGeometry.circular(
              Dimensions.radius * 0.8,
            ),
          ),
          child: TextWidget(
            fontSize: Dimensions.titleSmall,
            color: CustomColors.grayShade,
            description ?? "",
          ),
        ),
        if (attachments != null)
          TextWidget(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: Dimensions.verticalSize * 0.25,
            ),
            'Attachment',
            color: CustomColors.blackColor,
          ),
        if (attachments != null)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 120.h,
            child: ListView.builder(
              itemCount: attachments?.length ?? 0,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final String image =
                    (attachments?[index] != null &&
                        (attachments?[index]?.isNotEmpty ?? false))
                    ? attachments![index]!
                    : 'https://picsum.photos/200/300';
                final fixedUrl = image.replaceAll(r'\', '/');

                //
                final previewUrl =
                    (attachments?[index] != null &&
                        (attachments?[index]?.isNotEmpty ?? false))
                    ? fixedUrl
                    : image;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(12),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        Get.context!,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImageViewer(imageUrl: previewUrl),
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: previewUrl,
                        width: 120.w,
                        height: 120.h,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade300),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade400,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
