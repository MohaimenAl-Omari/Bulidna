import 'package:buildna/controller/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class ClickableImage extends StatelessWidget {
  const ClickableImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.text,
    this.onTap,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? text;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        imagePath.startsWith('http') || imagePath.startsWith('https');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final loader = Get.find<LoaderController>();
          loader.show();
          try {
            if (onTap != null) {
              final result = onTap!();
              if (result is Future) {
                await result;
              }
              
            }
          } finally {
            loader.hide();
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  isNetworkImage
                      ? CachedNetworkImage(
                        imageUrl: imagePath,
                        width: width,
                        height: height,
                        fit: fit,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      )
                      : Image.asset(
                        imagePath,
                        width: width,
                        height: height,
                        fit: fit,
                      ),
            ),
            if (text != null) Text(text!),
          ],
        ),
      ),
    );
  }
}
