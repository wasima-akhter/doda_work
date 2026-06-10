import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SafeSvgAsset extends StatelessWidget {
  final String? assetPath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;

  const SafeSvgAsset({
    super.key,
    required this.assetPath,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath == null || assetPath!.trim().isEmpty) {
      return errorWidget ??
          const Icon(Icons.image_not_supported_outlined, color: Colors.grey);
    }

    return SizedBox(
      height: height,
      width: width,
      child: FittedBox(
        fit: fit,
        child: SvgPicture.asset(
          assetPath!,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (_) =>
              placeholder ??
              const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          errorBuilder: (_, __, ___) =>
              errorWidget ??
              const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}
