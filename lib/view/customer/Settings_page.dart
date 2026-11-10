import 'package:buildna/controller/customer_controller.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:buildna/view/customer/contactUs.dart';
import 'package:buildna/view/customer/favorites_craftsman.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildna/controller/auth_controller.dart';

import '../../helpers/otp_session.dart';

class SettingsPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final RxInt selectedIndex = (-1).obs;

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Settings'.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Obx(() {
                    final user = authController.user;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              user.imageURL.value.isNotEmpty
                                  ? NetworkImage(user.imageURL.value)
                                  : const AssetImage(
                                        'assets/default_avatar.png',
                                      )
                                      as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username.value,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phoneNumber.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 20),
                _buildMenuItem(Icons.language, 'Languages'.tr, 0),
                _buildMenuItem(Icons.support_agent_outlined, 'Contact'.tr, 2),
                _buildMenuItem(
                  Icons.favorite,
                  'Favorites'.tr,
                  3,
                  iconColor: Colors.red,
                ),

                SizedBox(height: height / 3.9),
                const Divider(color: Colors.black, thickness: 1),
                _buildMenuItem(
                  Icons.logout,
                  'Log Out'.tr,
                  4,
                  iconColor: Colors.red,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index, {
    Color iconColor = Colors.black,
  }) {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: selectedIndex.value == index ? Colors.blue : iconColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: selectedIndex.value == index ? Colors.blue : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          selectedIndex.value = index;

          // Briefly highlight the selected item
          await Future.delayed(const Duration(milliseconds: 200));

          if (index == 0) {
            showLanguageSelectionDialog(Get.context!);
          } else if (index == 2) {
            await Get.to(() => ContactSupportPage());
          } else if (index == 3) {
            Get.put(CustomerController());
            await Get.to(() => FavoritesCraftsman());
          } else if (index == 4) {
            OtpSession.clear();
            FirebaseAuth.instance.signOut();
            await Get.offAll(() => LoginPage());
          }
          selectedIndex.value = -1;
        },
      ),
    );
  }

  void showLanguageSelectionDialog(BuildContext context) {
    RxString selectedLang = Get.locale?.languageCode.obs ?? 'en'.obs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  '🌐 Choose Language'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Language selection
                Obx(
                  () => Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          'assets/static/uk_flagg.png',
                          width: 32,
                          height: 32,
                        ),
                        title: const Text('English'),
                        trailing: Radio<String>(
                          value: 'en',
                          groupValue: selectedLang.value,
                          onChanged: (val) => selectedLang.value = val!,
                          activeColor: Colors.blueAccent,
                        ),
                        onTap: () => selectedLang.value = 'en',
                      ),
                      ListTile(
                        leading: Image.asset(
                          'assets/static/jor_flag.png',
                          width: 32,
                          height: 32,
                        ),
                        title: const Text('Arabic'),
                        trailing: Radio<String>(
                          value: 'ar',
                          groupValue: selectedLang.value,
                          onChanged: (val) => selectedLang.value = val!,
                          activeColor: Colors.orangeAccent,
                        ),
                        onTap: () => selectedLang.value = 'ar',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.updateLocale(Locale(selectedLang.value));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
