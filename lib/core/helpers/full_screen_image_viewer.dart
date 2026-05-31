import 'dart:io';

import '../utils/basic_import.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;

  const FullScreenImageViewer({super.key, this.imageUrl, this.imageFile});

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageFile != null) {
      image = Image.file(imageFile!, fit: BoxFit.contain);
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        fit: BoxFit.contain,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, error) {
          debugPrint('Image preview error: $error');

          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 56,
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to load image',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SizedBox.expand(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Center(
            child: Hero(
              tag: imageUrl ?? imageFile?.path ?? UniqueKey().toString(),
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}
