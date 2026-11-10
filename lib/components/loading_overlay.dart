import 'package:buildna/controller/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loader = Get.find<LoaderController>();

    return Obx(() => Stack(
          children: [
            child,
            if (loader.isLoading.value)
              Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ));
  }
}
