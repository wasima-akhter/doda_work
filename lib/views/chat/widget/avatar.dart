import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/helpers/full_screen_image_viewer.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double size;
  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool enablePreview;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.size = 48,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.enablePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageFile != null) {
      imageWidget = Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      );
    } else {
      imageWidget = Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: const Icon(Icons.person, color: Colors.white),
      );
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(color: borderColor ?? Colors.blue, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: imageWidget,
    );

    if (!enablePreview ||
        (imageFile == null && (imageUrl == null || imageUrl!.isEmpty))) {
      return avatar;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FullScreenImageViewer(imageUrl: imageUrl, imageFile: imageFile),
          ),
        );
      },
      child: avatar,
    );
  }
}
