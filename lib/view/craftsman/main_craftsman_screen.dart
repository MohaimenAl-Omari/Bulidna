import 'package:buildna/controller/nav_bar_controller.dart';
import 'package:buildna/view/craftsman/craftsman_chat_list.dart';
import 'package:buildna/view/craftsman/craftsman_homepage.dart';
import 'package:buildna/view/craftsman/craftsman_profile.dart';
import 'package:buildna/view/craftsman/settingescraftsman.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class MainCraftsmanScreen extends StatelessWidget {
  MainCraftsmanScreen({super.key});

  final NavBarController navController = Get.put(NavBarController());

  final iconList = [Icons.home, Icons.message, Icons.person, Icons.settings];

  final List<Widget> pages = [
    const CraftsmanHome(),
    CraftsmanChatList(),
    CraftsmanProfile(),
    SettingsCraftsmanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: navController.pageController,
        onPageChanged: navController.onPageChanged,
        physics:
            const NeverScrollableScrollPhysics(), // Optional: disable swipe if you want only tap nav
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        child: const Image(
          image: AssetImage('assets/static/Buildna_logo-removebg-preview.png'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => AnimatedBottomNavigationBar(
          icons: iconList,
          activeIndex: navController.selectedIndex.value,
          activeColor: Colors.yellow,
          inactiveColor: Colors.white,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          backgroundColor: Colors.black,
          onTap: navController.changeTab,
        ),
      ),
    );
  }
}
