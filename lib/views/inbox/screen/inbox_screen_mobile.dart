import 'dart:io';

import 'package:shimmer/shimmer.dart';

import '../../../core/utils/basic_import.dart';
import '../../../core/utils/extensions.dart';
import '../../chat/widget/avatar.dart';
import '../controller/inbox_controller.dart';

class InboxScreenMobile extends GetView<InboxController> {
  InboxScreenMobile({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        controller.getOldMessages(isPagination: true);
      }
    });

    ever(controller.messagesList, (_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          if (controller.shouldAutoScroll.value) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            controller.shouldAutoScroll.value = false;
          } else {
            final isNearBottom = _scrollController.position.pixels < 100;

            if (isNearBottom) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        }
      });
    });

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          Get.close(1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: Dimensions.appBarHeight * 1.4,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          flexibleSpace: Padding(
            padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: mainSpaceBet,
                children: [
                  Row(
                    crossAxisAlignment: crossCenter,
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      SizedBox(width: 10.w),
                      ProfileAvatarWidget(
                        imageUrl:
                            '${ApiEndPoints.mainDomain}/${controller.avatar}',
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: mainCenter,
                        children: [
                          Text(
                            controller.name ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Active now",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Obx(() {
                    if (controller.isBlockLoading.value) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: controller.isBlock.value ? 'Unblock' : 'Block',
                          child: TextWidget(
                            controller.isBlock.value ? 'Unblock' : 'Block',
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'Block') {
                          controller.blockUser();
                        } else if (value == 'Unblock') {
                          controller.unBlockUser();
                        }
                      },
                    );
                  }),

                  //
                  // Obx(
                  //   () => controller.isBlockLoading.value
                  //       ? CircularProgressIndicator()
                  //       : IconButton(
                  //           onPressed: () => controller.blockUser(),
                  //           icon: Icon(Icons.block),
                  //         ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ MESSAGES ------------------
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.messagesList.isEmpty) {
                  return const Center(child: InboxShimmerWidget());
                }

                if (controller.messagesList.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: CustomColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.forum_outlined,
                            size: 64,
                            color: CustomColors.primary,
                          ),
                        ),
                        SizedBox(height: Dimensions.verticalSize * 2),
                        Text(
                          "No Messages Yet",
                          style: TextStyle(
                            fontSize: Dimensions.titleLarge,
                            fontWeight: FontWeight.w700,
                            color: CustomColors.blackColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.verticalSize * 0.5),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.widthSize * 4,
                          ),
                          child: Text(
                            "Say hello! Your conversation with this provider starts here. Send a message to get things moving.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: Dimensions.bodyMedium,
                              fontWeight: FontWeight.w400,
                              color: CustomColors.grayShade,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: controller.messagesList.length,
                      itemBuilder: (context, index) {
                        final msg =
                            controller.messagesList[controller
                                    .messagesList
                                    .length -
                                1 -
                                index];
                        final isMe = msg["isMe"] as bool;
                        final messageType = msg["type"] ?? "text";
                        final isUploading = msg["isUploading"] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                ProfileAvatarWidget(
                                  size: 40.r,
                                  imageUrl:
                                      '${ApiEndPoints.mainDomain}/${controller.avatar}',
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    // ========== MULTIPLE IMAGES SECTION - IMPROVED ==========
                                    if (messageType == "image" &&
                                        msg["images"] != null &&
                                        (msg["images"] as List).isNotEmpty)
                                      _buildImageGrid(
                                        images: msg["images"] as List,
                                        width: width,
                                        isUploading: isUploading,
                                        isMe: isMe,
                                      ),

                                    if (messageType == "image" &&
                                        msg["images"] != null &&
                                        msg["message"] != null &&
                                        msg["message"].toString().isNotEmpty)
                                      const SizedBox(height: 6),

                                    // TEXT BUBBLE
                                    if (msg["message"] != null &&
                                        msg["message"].toString().isNotEmpty)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: width * 0.7,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isMe
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF0084FF),
                                                    Color(0xFF0066FF),
                                                  ],
                                                )
                                              : null,
                                          color: isMe ? null : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          msg["message"],
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 15,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 4),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            msg["formattedTime"] ?? "",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              (msg["isSent"] ?? true)
                                                  ? Icons.done_all
                                                  : Icons.access_time,
                                              size: 14,
                                              color: (msg["isSent"] ?? true)
                                                  ? Colors.blue[600]
                                                  : Colors.grey[500],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // PAGINATION LOADING
                    if (controller.isPaginationLoading.value)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

            // ------------------ SELECTED IMAGES PREVIEW (Multiple) ------------------
            Obx(() {
              if (controller.selectedImages.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(controller.selectedImages[index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Add more button if less than max
                    if (controller.selectedImages.length <
                        controller.maxImageCount)
                      GestureDetector(
                        onTap: controller.pickImagesFromGallery,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.grey[600],
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            // ------------------ INPUT FIELD ------------------
            Obx(() {
              if (controller.isBlock.value) {
                return BlockedChatNotice(
                  text: controller.isBlockedByMe.value
                      ? "You blocked this user"
                      : "You can't reply to this conversation",
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.blue[600]),
                        onPressed: controller.pickImageFromCamera,
                      ),
                      IconButton(
                        icon: Icon(Icons.photo, color: Colors.blue[600]),
                        onPressed: controller.showImagePickerOptions,
                      ),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: controller.textController,
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: "Aa",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.isProcessingImages.value
                              ? null
                              : controller.sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: controller.isProcessingImages.value
                                  ? LinearGradient(
                                      colors: [
                                        Colors.grey[400]!,
                                        Colors.grey[500]!,
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF0084FF),
                                        Color(0xFF0066FF),
                                      ],
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: controller.isProcessingImages.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ========== IMPROVED Image Grid for Multiple Images ==========

  Widget _buildImageGrid({
    required List images,
    required double width,
    required bool isUploading,
    required bool isMe,
  }) {
    final imageCount = images.length;
    final maxWidth = width * 0.7;

    if (imageCount == 1) {
      // Single image - optimized size
      return _buildSingleImage(
        images[0],
        maxWidth,
        isUploading,
        isMe,
        isSingle: true,
      );
    } else if (imageCount == 2) {
      return SizedBox(
        width: maxWidth,
        child: Row(
          children: [
            Expanded(
              child: _buildSingleImage(
                images[0],
                maxWidth / 2,
                isUploading,
                isMe,
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: _buildSingleImage(
                images[1],
                maxWidth / 2,
                isUploading,
                isMe,
              ),
            ),
          ],
        ),
      );
    } else if (imageCount == 3) {
      return SizedBox(
        width: maxWidth,
        child: Column(
          children: [
            _buildSingleImage(
              images[0],
              maxWidth,
              isUploading,
              isMe,
              height: 200,
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[1],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 120,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _buildSingleImage(
                    images[2],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 120,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (imageCount == 4) {
      return SizedBox(
        width: maxWidth,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[0],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _buildSingleImage(
                    images[1],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[2],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _buildSingleImage(
                    images[3],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: maxWidth,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[0],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: _buildSingleImage(
                    images[1],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: _buildSingleImage(
                    images[2],
                    maxWidth / 2,
                    isUploading,
                    isMe,
                    height: 140,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Stack(
                    children: [
                      _buildSingleImage(
                        images[3],
                        maxWidth / 2,
                        isUploading,
                        isMe,
                        height: 140,
                      ),
                      // +N Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '+${imageCount - 4}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSingleImage(
    String imagePath,
    double width,
    bool isUploading,
    bool isMe, {
    double? height,
    bool isSingle = false,
  }) {
    final cleanPath = imagePath
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '');
    final fullImageUrl = cleanPath;

    final imageWidget = Image.network(
      fullImageUrl,
      // ✅ Single image: no fixed width/height, let it maintain aspect ratio
      fit: isSingle ? BoxFit.contain : BoxFit.cover,
      // Only set constraints for grid images, not single
      width: isSingle ? null : double.infinity,
      height: isSingle ? null : (height ?? 180),
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: isSingle ? null : double.infinity,
          height: isSingle ? 200 : (height ?? 180),
          constraints: isSingle
              ? BoxConstraints(
                  maxWidth: width * 0.85,
                  minWidth: 200,
                  minHeight: 150,
                )
              : null,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: isSingle ? null : double.infinity,
          height: isSingle ? 200 : (height ?? 180),
          constraints: isSingle
              ? BoxConstraints(
                  maxWidth: width * 0.85,
                  minWidth: 200,
                  minHeight: 150,
                )
              : null,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );

    return Stack(
      children: [
        // ✅ For single image, add constraints container
        isSingle
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width * 0.85, // Max 85% of message width
                  maxHeight: 400, // Max height to prevent too tall images
                  minWidth: 200, // Min width for very small images
                  minHeight: 150, // Min height
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageWidget,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageWidget,
              ),
        // Uploading overlay
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Uploading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class InboxShimmerWidget extends StatelessWidget {
  const InboxShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: SafeArea(
        child: Column(
          children: [
            Space.height.v20,
            Expanded(
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: 20,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isMe = index % 2 == 0;

                  return Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width * 0.4,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: width * 0.15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlockedChatNotice extends StatelessWidget {
  final String text;

  const BlockedChatNotice({
    super.key,
    this.text = "You can’t reply to this conversation",
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
