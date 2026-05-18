part of 'document_screen.dart';

class DocumentScreenMobile extends GetView<DocumentController> {
  const DocumentScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(title: 'Document'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            _buildSectionCard(
              Icons.dock,
              "Licence",
              () => Get.toNamed(Routes.licenceScreen),
            ),
            // _buildSectionCard(
            //   Icons.vertical_shades_closed,
            //   "certificate",
            //   () => Get.toNamed(Routes.certificateScreen),
            // ),
            Space.height.betweenInputBox,
            Space.height.betweenInputBox,
          ],
        ),
      ),
    );
  }
}

_buildSectionCard(IconData icon, String title, void Function()? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsetsGeometry.only(top: Dimensions.heightSize),
      height: Dimensions.heightSize * 4.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        border: Border.all(color: Colors.grey.withAlpha(555)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          Wrap(
            spacing: Dimensions.defaultHorizontalSize * 0.2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                onPressed: null,
                icon: Icon(icon, color: CustomColors.primary),
              ),

              TextWidget(title, fontSize: Dimensions.titleSmall * 1.1),
            ],
          ),

          IconButton(
            onPressed: null,
            icon: Icon(Icons.arrow_forward_ios, color: CustomColors.primary),
          ),
        ],
      ),
    ),
  );
}
