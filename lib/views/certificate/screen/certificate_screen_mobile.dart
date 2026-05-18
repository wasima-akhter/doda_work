part of 'certificate_screen.dart';

class CertificateScreenMobile extends GetView<CertificateController> {
  const CertificateScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Certificate'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            // Add your widgets here
            Obx(() {
              final items = [...controller.photos];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var photo in items)
                    Container(
                      width: 100.w,
                      height: 90.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius * 0.8,
                        ),
                        image: DecorationImage(
                          image: FileImage(photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      width: 100.w,
                      height: 90.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange,
                          style: BorderStyle.solid,
                        ),
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
            Row(
              children: [
                Expanded(
                  child: PrimaryButtonWidget(title: 'Update', onPressed: () {}),
                ),
                Space.width.v10,
                Expanded(
                  child: PrimaryButtonWidget(
                    title: 'Add More',
                    outlineButton: true,
                    onPressed: () => controller.pickImage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
