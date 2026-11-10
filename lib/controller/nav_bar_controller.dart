import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  final pageController = PageController();
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
