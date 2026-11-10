import 'package:flutter/material.dart';

class Dropdownlist<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabelBuilder;
  final String? hintText;

  const Dropdownlist({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DropdownButtonFormField<T>(
        value: selectedItem,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items:
            items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabelBuilder(item)),
              );
            }).toList(),
      ),
    );
  }
}
