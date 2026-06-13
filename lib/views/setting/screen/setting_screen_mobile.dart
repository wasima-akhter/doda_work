part of 'setting_screen.dart';

class SettingScreenMobile extends GetView<SettingController> {
  const SettingScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingController());
    return Scaffold(
      appBar: AuthAppBar(title: 'Account Setting'),
      body: SafeArea(
        child: ListView(
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          children: [
            Space.height.v10,
            _buildSectionCard(
              Icons.lock,
              'Change Password',
              () => Get.toNamed(Routes.changePasswordScreen),
              false,
            ),
            _buildSectionCard(
              Icons.person,
              'Delete Account',
              () => _showDeleteDialog(),
              true,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    final controller = Get.find<SettingController>();

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        contentPadding: const EdgeInsets.all(16),
        title: const TextWidget('Delete Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryInputFieldWidget(
                controller: controller.emailController,
                label: "Email",
                hintText: "Enter your email",
              ),
              Space.height.v10,
              PrimaryInputFieldWidget(
                controller: controller.passwordController,
                label: "Password",
                hintText: "Enter your password",
                isPassword: true,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearForm();
            },
            child: const TextWidget('No'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      await controller.deleteUserAccount(
                        email: controller.emailController.text.trim(),
                        password: controller.passwordController.text.trim(),
                      );
                      controller.clearForm();
                    },
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: const CircularProgressIndicator(
                        color: CustomColors.primary,
                      ),
                    )
                  : const TextWidget('Yes'),
            ),
          ),
        ],
      ),
    );
  }

  _buildSectionCard(
    IconData icon,
    String title,
    void Function()? onTap,
    bool isRed,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: Dimensions.heightSize),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.heightSize * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          border: Border.all(color: Colors.grey.withAlpha(150)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isRed ? CustomColors.rejected : CustomColors.primary,
                  ),
                  SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
                  Expanded(
                    child: TextWidget(
                      title,
                      fontSize: Dimensions.titleSmall * 1.1,
                      color: isRed
                          ? CustomColors.rejected
                          : CustomColors.blackColor,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isRed ? CustomColors.rejected : CustomColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
