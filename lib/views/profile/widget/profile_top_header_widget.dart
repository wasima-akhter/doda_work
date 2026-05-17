import 'package:shadify/shadify.dart';

import '../../../core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../controller/profile_controller.dart';

class ProfileTopHeaderWidgetView extends GetView<ProfileController> {
  const ProfileTopHeaderWidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width * 0.28;
    final double cardHeight = MediaQuery.of(context).size.height * 0.12;

    return Obx(() {
      // Get user data
      final userData = controller.userProfileModel.value?.data;

      // Profile image URL

      return Container(
        // height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          border: Border.all(color: Colors.grey.withAlpha(555)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius * 0.8),
                bottomLeft: Radius.circular(Dimensions.radius * 0.8),
              ),
              child: CachedNetworkImage(
                imageUrl: userData?.profileImage ?? '',
                width: imageWidth * 0.85,
                height: cardHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade400,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Space.width.v10,

            // User Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSize * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User Name
                    TextWidget(
                      userData?.name ?? "User Name",
                      fontSize: Dimensions.titleSmall,
                      fontWeight: FontWeight.w600,
                      color: CustomColors.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),

                    Space.height.v5,

                    // Email
                    TextWidget(
                      userData?.email ?? "user@example.com",
                      fontSize: Dimensions.titleSmall * 0.85,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),

                    Space.height.v5,

                    // Phone Number
                    if (userData?.phoneNumber?.isNotEmpty == true)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: Dimensions.iconSizeSmall,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: TextWidget(
                              userData?.phoneNumber ?? '',
                              fontSize: Dimensions.titleSmall * 0.8,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Edit Button
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.updateScreen),
                child: Container(
                  margin: EdgeInsets.all(Dimensions.paddingSize * 0.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize * 0.3,
                    vertical: Dimensions.verticalSize * 0.2,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: CustomColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        color: CustomColors.primary,
                        size: Dimensions.iconSizeSmall * 1.2,
                      ),
                      SizedBox(width: 4),
                      TextWidget(
                        'Edit',
                        fontSize: Dimensions.titleSmall * 0.7,
                        color: CustomColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).withShadifyLoading(loading: controller.isLoading.value);
    });
  }
}

class ProfileTopWidgetView extends GetView<ProfileController> {
  const ProfileTopWidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width * 0.28;
    final double cardHeight = MediaQuery.of(context).size.height * 0.12;

    return Obx(() {
      final providerData = controller.providerProfileModel.value?.data;

      return Container(
        // height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
          border: Border.all(color: Colors.grey.withAlpha(555)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radius * 0.8),
                bottomLeft: Radius.circular(Dimensions.radius * 0.8),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    providerData?.profileImage ??
                    'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png',
                width: imageWidth * 0.85,
                height: cardHeight,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey.shade300),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade400,
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),

            Space.width.v10,

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSize * 0.2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      controller.providerProfileModel.value?.data.companyName ??
                          '',
                      fontSize: Dimensions.titleSmall,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    Space.height.v5,
                    TextWidget(
                      controller
                              .providerProfileModel
                              .value
                              ?.data
                              .authId
                              .email ??
                          '',
                      fontSize: Dimensions.titleSmall,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    Space.height.v5,
                    TextWidget(
                      controller.providerProfileModel.value?.data.website ?? '',
                      fontSize: Dimensions.titleSmall,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.vendorProfileScreen),
                child: Container(
                  margin: EdgeInsets.all(Dimensions.paddingSize * 0.2),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize * 0.2,
                    vertical: Dimensions.verticalSize * 0.1,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: CustomColors.primary),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 0.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        color: CustomColors.primary,
                        size: Dimensions.iconSizeSmall * 1.4,
                      ),
                      TextWidget(
                        'Edit',
                        fontSize: Dimensions.titleSmall * 0.6,
                        color: CustomColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).withShadifyLoading(loading: controller.isLoading.value);
    });
  }
}
