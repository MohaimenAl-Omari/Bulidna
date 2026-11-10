import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:buildna/view/customer/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/otp_session.dart';

class CustomerProfilePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final bool isSmallScreen = width < 600;
        final bool isPortrait = height > width;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: isSmallScreen ? 18 : 24,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.black54,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: () {
                  OtpSession.clear();
                  FirebaseAuth.instance.signOut();
                  Get.offAll(() => LoginPage());
                },
              ),
            ],
          ),
          body: Obx(() {
            final user = authController.user;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? width * 0.04 : width * 0.1,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: isPortrait ? height * 0.03 : height * 0.05,
                    ),
                    // Profile avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: isSmallScreen ? 3 : 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius:
                            isSmallScreen
                                ? (isPortrait ? height * 0.1 : width * 0.1)
                                : (isPortrait ? height * 0.08 : width * 0.08),
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            user.imageURL.value.isNotEmpty
                                ? NetworkImage(user.imageURL.value)
                                : const AssetImage(
                                      'assets/static/profilePhoto.jpg',
                                    )
                                    as ImageProvider,
                        child:
                            user.imageURL.value.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: isSmallScreen ? 50 : 70,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    // Name
                    Text(
                      user.username.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 12),
                    SizedBox(height: isSmallScreen ? 20 : 40),
                    // Information Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            context,
                            Icons.email,
                            'Email'.tr,
                            user.email.value,
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          _infoRow(
                            context,
                            Icons.phone,
                            'Phone Number',
                            user.phoneNumber.value,
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          _infoRow(
                            context,
                            Icons.location_city,
                            'City'.tr,
                            user.city.value,
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          _infoRow(
                            context,
                            Icons.person_outline,
                            'Gender'.tr,
                            user.gender.value,
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 30 : 50),
                    // Edit Profile Button
                    SizedBox(
                      width:
                          isSmallScreen
                              ? width * 0.7
                              : (isPortrait ? width * 0.4 : width * 0.3),
                      height: isSmallScreen ? 48 : 56,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => EditCustomerProfile()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: isSmallScreen ? 18 : 22),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height / 30),
                    SizedBox(
                      width:
                          isSmallScreen
                              ? width * 0.7
                              : (isPortrait ? width * 0.4 : width * 0.3),
                      height: isSmallScreen ? 48 : 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show confirmation dialog first
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Delete Account'.tr),
                                  content: Text(
                                    'Are you sure you want to delete your account? This action cannot be undone.'
                                        .tr,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: Text('Cancel'.tr),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: Text('Delete'.tr),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmDelete) {
                            try {
                              await authController.deleteUserAccount();
                              // Clear navigation stack and go to login
                              Get.offAll(() => LoginPage());
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Could not delete account. Please try again.',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: isSmallScreen ? 18 : 22),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Text(
                              'Delete Account'.tr,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 14 : 20,
        horizontal: isSmallScreen ? 16 : 24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Text(
                  value.isNotEmpty ? value : 'Unknown',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
