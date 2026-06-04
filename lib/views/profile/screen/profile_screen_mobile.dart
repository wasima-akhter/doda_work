part of 'profile_screen.dart';

class ProfileScreenMobile extends GetView<ProfileController> {
  const ProfileScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimensions.appBarHeight * 2.25,
        scrolledUnderElevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            child: Row(
              mainAxisAlignment: mainSpaceBet,
              children: [
                AppBarLogoWidget(),
                TextWidget(
                  'Profile',
                  color: CustomColors.blackColor,
                  fontSize: Dimensions.titleMedium * 1.2,
                  fontWeight: FontWeight.w600,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => controller.loadProfile(),
                      child: Container(
                        padding: EdgeInsets.all(Dimensions.paddingSize * 0.35),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CustomColors.primary),
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: CustomColors.primary,
                          size: Dimensions.iconSizeLarge * 0.8,
                        ),
                      ),
                    ),
                    Space.width.v10,

                    /// NOTIFICATION ICON
                    NotificationIcon(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? LoadingWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadProfile();
                  },
                  color: CustomColors.primary,
                  child: ListView(
                    padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
                    children: [
                      if (AppStorage.users == 'USER')
                        ProfileTopHeaderWidgetView(),
                      if (AppStorage.users == 'PROVIDER')
                        ProfileTopWidgetView(),

                      Space.height.v10,

                      if (AppStorage.users == 'PROVIDER')
                        Container(
                          padding: Dimensions.heightSize.edgeVertical,
                          decoration: BoxDecoration(
                            color: CustomColors.whiteColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 0.8,
                            ),
                            border: Border.all(
                              color: Colors.grey.withAlpha(555),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: Dimensions.paddingSize.edgeHorizontal / 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  'Online Status',
                                  color: CustomColors.blackColor,
                                  fontSize: Dimensions.titleSmall * 1.1,
                                  fontWeight: FontWeight.w500,
                                ),

                                Obx(
                                  () => OnlineStatus(
                                    initialValue: controller.isOnline.value,
                                    onChanged: controller.toggleOnlineStatus,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Space.height.v10,
                      ProfileCardSectionWidgetView(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class OnlineStatus extends StatefulWidget {
  final bool initialValue;
  final Future<void> Function(bool value) onChanged;

  const OnlineStatus({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<OnlineStatus> createState() => _OnlineStatusState();
}

class _OnlineStatusState extends State<OnlineStatus> {
  late bool isOnline;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isOnline = widget.initialValue;
  }

  Future<void> _handleToggle(bool value) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await widget.onChanged(value);

      setState(() {
        isOnline = value; // update only after success
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant OnlineStatus oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        isOnline = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: AnimatedToggleSwitch<bool>.dual(
            current: isOnline,
            loading: isLoading,

            loadingIconBuilder: (context, props) {
              return Container(
                width: 18,
                height: 18,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomColors.primary,
                ),
              );
            },
            first: false,
            second: true,

            fittingMode: FittingMode.preventHorizontalOverlapping,

            height: 30,
            spacing: -4,

            indicatorSize: const Size(25, 24),

            borderWidth: 2,

            style: ToggleStyle(
              borderRadius: BorderRadius.circular(30),
              backgroundColor: Colors.grey.shade300,
              borderColor: Colors.transparent,
              // 👇 IMPORTANT: remove indicator “loading tint”
              indicatorColor: Colors.white,
              indicatorGradient: null,
            ),

            styleBuilder: (value) => ToggleStyle(
              backgroundColor: value
                  ? CustomColors.primary
                  : Colors.grey.shade300,
            ),

            iconBuilder: (value) => Container(
              width: 28,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.white : CustomColors.grayShade,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            textBuilder: (value) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                value ? 'ON' : 'OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            onChanged: _handleToggle,
          ),
        ),

        // if (isLoading)
        //   Container(
        //     width: 30,
        //     height: 30,
        //     decoration: BoxDecoration(
        //       color: Colors.black.withOpacity(0.1),
        //       shape: BoxShape.circle,
        //     ),
        //     child: const Padding(
        //       padding: EdgeInsets.all(6),
        //       child: LoadingWidget(color: Colors.white),
        //     ),
        //   ),
      ],
    );
  }
}
