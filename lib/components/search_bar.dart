import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key, required this.width, required this.text});
  final double width;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 240, 247),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          hintText: text,
        ),
      ),
    );
  }
}
