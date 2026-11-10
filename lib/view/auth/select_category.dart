import 'package:buildna/components/custom_clickable_image.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/view/craftsman/register_info_craftsman.dart';
import 'package:buildna/view/customer/register_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectCategory extends StatelessWidget {
  SelectCategory({super.key});
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height / 10),
              const Text(
                'Select which one\nyou are',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height / 17),
              Container(
                padding: EdgeInsets.only(top: height / 7),
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    // Top shadow
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, -30), // negative Y for top
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClickableImage(
                          imagePath: 'assets/static/customer.png',
                          height: height / 7,
                          width: height / 7,
                          text: 'Customer',
                          onTap: () {
                            Get.to(() => RegisterInfo());
                          },
                        ),
                        ClickableImage(
                          imagePath: 'assets/static/craftsman.png',
                          height: height / 7,
                          width: height / 7,
                          text: 'Craftsman',
                          onTap: () {
                            Get.to(() => RegisterInfoCraftsman());
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: height / 15),
                    ClickableImage(
                      imagePath: 'assets/static/shop.png',
                      height: height / 7,
                      width: height / 7,
                      text: 'Shop',
                      onTap: () {
                        Get.defaultDialog(
                          title: '🚧 Coming Soon!',
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.teal,
                          ),
                          middleText:
                              'The shop will be available in the next version.',
                          middleTextStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          backgroundColor: Colors.white,
                          radius: 20,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          confirm: ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
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
