import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    required this.textController,
    this.validator,
    this.maxLines,
    this.textDirection = TextDirection.ltr,
  });
  final String? hint;
  final String label;
  final TextEditingController textController;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextDirection textDirection;
  @override
  Widget build(BuildContext context) {
    final locale = Get.locale;
    return Column(
      children: [
        Align(
          alignment:
              locale!.languageCode == 'en'
                  ? Alignment.topLeft
                  : Alignment.topRight,
          child: Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
        ),
        TextFormField(
          textDirection: textDirection,
          maxLines: maxLines,
          validator: validator,
          controller: textController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 10.0,
            ),
            hintText: hint,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 10),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
