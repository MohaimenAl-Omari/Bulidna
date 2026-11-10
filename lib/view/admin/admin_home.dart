import 'package:buildna/controller/admin_controller.dart';
import 'package:buildna/view/admin/CraftsmanDetailsPage.dart';
import 'package:buildna/view/admin/admin_settings.dart';
import 'package:buildna/view/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/otp_session.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AdminController adminController = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    adminController.getPendingCraftsmen(); // Fetch pending craftsmen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Get.to(()=>AdminSettings());
          }, icon: const Icon(Icons.settings))
        ],
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined, size: 24, color: Colors.red),
          onPressed: () async{
            OtpSession.clear();
            FirebaseAuth.instance.signOut();
            Get.offAll(() => LoginPage());
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (adminController.pendingCraftsmen.isEmpty) {
          return const Center(
            child: Text(
              'No pending craftsmen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: adminController.pendingCraftsmen.length,
          itemBuilder: (context, index) {
            final craftsman = adminController.pendingCraftsmen[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                title: Text(
                  craftsman['username'] ?? 'No name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  craftsman['Speciality'] ?? 'No speciality',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.to(
                      () => CraftsmanDetailsPage(
                        craftsmanId: craftsman['craftsmanId'],
                      ),
                    );
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
