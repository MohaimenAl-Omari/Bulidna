import 'package:buildna/components/custom_button.dart';
import 'package:buildna/components/custom_text_field.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactSupportPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController issueController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height / 15),
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(80),
                  ),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, -10),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    /// Profile Image
                    Positioned(
                      top: -40,
                      child: Obx(() {
                        final user = authController.user;
                        return CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              user.imageURL.value.isNotEmpty
                                  ? NetworkImage(user.imageURL.value)
                                  : const AssetImage(
                                        'assets/default_avatar.png',
                                      )
                                      as ImageProvider,
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Get in ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'touch',
                                      style: TextStyle(color: Colors.teal),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: height / 22),
                            CustomTextField(
                              label: 'Full Name'.tr,
                              textController: nameController,
                              hint: '',
                            ),
                            SizedBox(height: height / 50),
                            CustomTextField(
                              label: 'Phone Number'.tr,
                              textController: phoneController,
                              hint: '',
                            ),
                            SizedBox(height: height / 50),
                            CustomTextField(
                              hint: '',
                              label: 'Describe your issue'.tr,
                              textController: issueController,
                              maxLines: 5,
                            ),
                            SizedBox(height: height / 15),
                            CustomButton(
                              text: 'Submit',
                              onPressed: () async {
                                if (nameController.text.isEmpty ||
                                    phoneController.text.isEmpty ||
                                    issueController.text.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Please fill all fields',
                                  );
                                  return;
                                }
                                await authController.saveContactUs(
                                  fullName: nameController.text,
                                  email: phoneController.text,
                                  issue: issueController.text,
                                );
                                Get.snackbar(
                                  'Success',
                                  'Your request has been sent.',
                                );
                              },
                              height: height / 14.6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
