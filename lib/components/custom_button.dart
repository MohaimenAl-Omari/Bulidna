import 'package:buildna/controller/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.height,
    this.fontSize,
    this.borderRadius,
    this.width,
    this.color,
    this.textColor,
  });
  final Function()? onPressed;
  final String text;
  final double height;
  final double? fontSize;
  final double? borderRadius;
  final double? width;
  final Color? color;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        onPressed: () async {
          final loader = Get.find<LoaderController>();
          loader.show();
          try {
            if (onPressed != null) {
              final result = onPressed!();
              if (result is Future) {
                await result;
              }
            }
          } finally {
            loader.hide();
          }
        },
        color: color ?? Colors.black,
        child: Center(
          // 👈 Make sure text is centered vertically
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: fontSize ?? 22,
            ),
          ),
        ),
      ),
    );
  }
}
