part of 'congratulations_screen.dart';

class CongratulationsScreenMobile extends GetView<CongratulationsController> {
  const CongratulationsScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AuthAppBar(title: ""),
      bottomNavigationBar: PrimaryButtonWidget(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize * 2,
        ),
        title: 'Go To Home',
        onPressed: () => Get.offAllNamed(Routes.navigationScreen),
      ),
      body: SafeArea(
        child: Padding(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          child: ConfirmationWidget(
            title: 'Payment Completed',
            subtitle: 'Your transaction has been processed successfully',
          ),
        ),
      ),
    );
  }
}

class Congratulation extends StatelessWidget {
  const Congratulation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AuthAppBar(title: ""),
      bottomNavigationBar: PrimaryButtonWidget(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize * 2,
        ),
        title: 'Go To Home',
        onPressed: () => Get.offAllNamed(Routes.navigationScreen),
      ),
      body: SafeArea(
        child: Padding(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          child: ConfirmationWidget(
            title: 'Product Added Successfully',
            subtitle: """
"Your Product Added Successfully
You can see from my Product"
""",
          ),
        ),
      ),
    );
  }
}

class ConfirmationWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const ConfirmationWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: crossCenter,
        mainAxisAlignment: mainCenter,
        children: [
          Icon(
            Icons.verified_rounded,
            size: Dimensions.iconSizeLarge * 5,
            color: CustomColors.primary,
          ),
          TextWidget(
            padding: EdgeInsetsGeometry.only(
              top: Dimensions.heightSize * 2,
              bottom: Dimensions.heightSize,
            ),
            title,
            fontWeight: titleStyle?.fontWeight ?? FontWeight.bold,
            fontSize: titleStyle?.fontSize ?? Dimensions.titleMedium * 1.2,
            color: titleStyle?.color,
          ),
          TextWidget(
            textAlign: TextAlign.center,
            subtitle,
            color: subtitleStyle?.color ?? CustomColors.grayShade,
            fontSize: subtitleStyle?.fontSize ?? Dimensions.titleSmall,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
