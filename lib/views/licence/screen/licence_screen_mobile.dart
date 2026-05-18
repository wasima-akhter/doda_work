part of 'licence_screen.dart';

class LicenceScreenMobile extends GetView<LicenceController> {
  const LicenceScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Licence'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Obx(() {
              final newItems = controller.photos;
              final oldItems = controller.oldPhotos;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (oldItems.isNotEmpty) ...[
                    ...oldItems.map(
                      (imgUrl) => Stack(
                        children: [
                          Container(
                            width: 100.w,
                            height: 90.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius * 0.8,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(imgUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // delete button
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeOldImage(imgUrl),
                              child: const CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ...newItems.map(
                    (photo) => Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 0.8,
                            ),
                            image: DecorationImage(
                              image: FileImage(photo),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // ❌ Delete button for new image
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => controller.photos.remove(photo),
                            child: const CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      width: 100.w,
                      height: 90.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius * 0.8,
                        ),
                        color: Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.orange,
                          size: Dimensions.iconSizeLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            Space.height.v20,
            Obx(() {
              final isLoading = controller.isUpdateLoading.value;
              return Row(
                children: [
                  Expanded(
                    child: PrimaryButtonWidget(
                      title: isLoading ? 'Updating...' : 'Update',
                      onPressed: () {
                        if (!isLoading) {
                          controller.updateProfile(body: {});
                        }
                      },
                    ),
                  ),
                  Space.width.v10,

                  /*     Expanded(
                    child: PrimaryButtonWidget(
                      title: 'Add More',
                      outlineButton: true,
                      onPressed: controller.pickImage,
                    ),
                  ),*/
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
