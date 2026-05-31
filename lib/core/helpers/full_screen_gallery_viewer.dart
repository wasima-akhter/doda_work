import 'package:flutter/material.dart';

import '../utils/basic_import.dart';

class FullScreenGalleryViewer extends StatefulWidget {
  final List images;
  final int initialIndex;

  const FullScreenGalleryViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGalleryViewer> createState() =>
      _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<FullScreenGalleryViewer> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
  }

  String _cleanUrl(String url) {
    return url.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ===== APP BAR (with safe back button) =====
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ===== IMAGE VIEWER =====
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final raw = widget.images[index].toString();
          final url = _cleanUrl(raw);

          return Center(
            child: Hero(
              tag: url.isNotEmpty ? url : 'image_$index',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                child: _buildImage(url),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== IMAGE BUILDER WITH SAFETY =====
  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return _errorWidget("Invalid image");
    }

    return Image.network(
      url,
      fit: BoxFit.contain,

      // ===== LOADING =====
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      },

      // ===== ERROR HANDLING =====
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Gallery image error: $error");
        return _errorWidget("Unable to load image");
      },
    );
  }

  // ===== FALLBACK UI =====
  Widget _errorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.broken_image_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 12),
          Text("Image not available", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
